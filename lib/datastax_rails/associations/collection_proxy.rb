module DatastaxRails
  module Associations
    # Association proxies in DatastaxRails are middlemen between the object that
    # holds the association, known as the <tt>@owner</tt>, and the actual associated
    # object, known as the <tt>@target</tt>. The kind of association any proxy is
    # about is available in <tt>@reflection</tt>. That's an instance of the class
    # DatastaxRails::Reflection::AssociationReflection.
    #
    # For example, given
    #
    #   class Blog < DatastaxRails::Base
    #     has_many :posts
    #   end
    #
    #   blog = Blog.first
    #
    # the association proxy in <tt>blog.posts</tt> has the object in +blog+ as
    # <tt>@owner</tt>, the collection of its posts as <tt>@target</tt>, and
    # the <tt>@reflection</tt> object represents a <tt>:has_many</tt> macro.
    #
    # This class has most of the basic instance methods removed, and delegates
    # unknown methods to <tt>@target</tt> via <tt>method_missing</tt>. As a
    # corner case, it even removes the +class+ method and that's why you get
    #
    #   blog.posts.class # => Array
    #
    # though the object behind <tt>blog.posts</tt> is not an Array, but an
    # DatastaxRails::Associations::HasManyAssociation.
    #
    # The <tt>@target</tt> object is not \loaded until needed. For example,
    #
    #   blog.posts.count
    #
    # is computed directly through Solr and does not trigger by itself the
    # instantiation of the actual post records.
    class CollectionProxy #:nodoc:
      alias :proxy_extend :extend
      
      instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|^respond_to|proxy_/ }
      
      delegate :order, :limit, :where, :to => :scoped
      delegate :target, :load_target, :loaded?, :scoped, :to => :@association
      delegate :select, :find, :first, :last, :build, :create, :create!, :destroy_all, :destroy,
               :delete, :delete_all, :count, :size, :length, :empty?, :any?, :many?, :to => :@association
               
      def initialize(association)
        @association = association
        Array.wrap(association.options[:extend]).each { |ext| proxy_extend(ext) }
      end
      
      alias_method :new, :build
      
      def proxy_association
        @association
      end
      
      def respond_to?(name, include_private = false)
        super ||
        (load_target && target.respond_to?(name, include_private)) ||
        proxy_association.klass.respond_to?(name, include_private)
      end
      
      def method_missing(method, *args, &block)
        if target.respond_to?(method) || (!proxy_association.klass.respond_to?(method) && Class.respond_to?(method))
          if load_target
            if target.respond_to?(method)
              target.send(method, *args, &block)
            else
              begin
                super
              rescue NoMethodError => e
                raise e, e.message.sub(/ for #<.*$/, " via proxy for #{target}")
              end
            end
          end

        else
          scoped.send(method, *args, &block)
        end
      end
      
      # Forwards <tt>===</tt> explicitly to the \target because the instance method
      # removal above doesn't catch it. Loads the \target if needed.
      def ===(other)
        other === load_target
      end
      
      def to_ary
        load_target.dup
      end
      alias_method :to_a, :to_ary
      
      def <<(*records)
        proxy_association.concat(records) && self
      end
      alias_method :push, :<<
      
      def clear
        destroy_all
        self
      end
      
      def reload
        proxy_association.reload
        self
      end
    end
  end
end
