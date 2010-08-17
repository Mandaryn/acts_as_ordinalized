module ActsAsOrdinalized
  def self.included(base)
    base.extend ClassMethods
  end

  # this acts_as extension add ordinal numbers to active record collections
  # each collection gets new ordinal numbers starting from one
  # paginated results should also get correct ordinal numbers on subsequent pages
  module ClassMethods
    def acts_as_ordinalized
      attr_accessor :ordinal_number

      #wrap find with function adding ordinal numbers to all returned models
      if self.respond_to?(:paginate)
        def self.paginate(*args)
          ActsAsOrdinalized.ordinalize(super(*args))
        end
      end
      def self.find(*args)
        ActsAsOrdinalized.ordinalize(super(*args))
      end
    end
  end

  protected

  def self.ordinalize(collection_or_object)
    ordinal_base = 1
    # if pagination present correct the ordinal base
    if collection_or_object.respond_to?(:current_page) && collection_or_object.respond_to?(:per_page)
      ordinal_base = (collection_or_object.current_page - 1) * collection_or_object.per_page + 1
    end
    if collection_or_object.is_a?(Array)
      collection_or_object.each_with_index do |item, index|
        item.ordinal_number = ordinal_base + index
      end
    elsif !collection_or_object.nil?
      collection_or_object.ordinal_number = ordinal_base
    end
    collection_or_object
  end
end

ActiveRecord::Base.class_eval { include ActsAsOrdinalized }