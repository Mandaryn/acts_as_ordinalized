require 'test/unit'

require 'rubygems'
gem 'activerecord'
require 'active_record'
require 'will_paginate'
WillPaginate.enable_activerecord

require "#{File.dirname(__FILE__)}/../lib/acts_as_ordinalized"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :ordinals do |t|
      t.column :test_order, :integer
      t.column :switch, :boolean
    end

    create_table :more_ordinals do |t|
      t.column :test_order, :integer
      t.column :switch, :boolean
      t.column :ordinal_id, :integer
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Ordinal < ActiveRecord::Base
  acts_as_ordinalized
  has_many :more_ordinals
end

class OrdinalTest < Test::Unit::TestCase

  def setup
    setup_db
    (1..5).each { |counter| Ordinal.create!(:test_order => "#{counter}", :switch => counter.even?) }
  end

  def teardown
    teardown_db
  end

  def test_ordinalizing
    ordinals = Ordinal.all(:order => "test_order ASC")
    assert_equal [[1,1], [2,2], [3,3], [4,4], [5,5]], ordinals.map{|o| [o.test_order, o.ordinal_number] }
    reversed = Ordinal.all(:order => "test_order DESC")
    assert_equal [[5,1], [4,2], [3,3], [2,4], [1,5]], reversed.map{|o| [o.test_order, o.ordinal_number] }
    even = Ordinal.all(:conditions => { :switch => true }, :order => "test_order ASC")
    assert_equal [[2,1], [4,2]], even.map{|o| [o.test_order, o.ordinal_number] }
  end

  def test_nil_and_empty_results
    empty = Ordinal.all(:conditions => ['test_order > 15'])
    assert_equal [], empty
    empty = Ordinal.last(:conditions => ['test_order > 15'])
    assert_equal nil, empty
  end
end

class OrdinalWithPaginationTest < Test::Unit::TestCase

  def setup
    setup_db
    (1..10).each { |counter| Ordinal.create!(:test_order => "#{counter}", :switch => counter.even?) }
  end

  def teardown
    teardown_db
  end

  def test_ordinal_with_pagination
    ordinals = Ordinal.paginate(:page => 1, :per_page => 5, :order => "test_order ASC")
    assert_equal [[1,1], [2,2], [3,3], [4,4], [5,5]], ordinals.map{|o| [o.test_order, o.ordinal_number] }
    ordinals2 = Ordinal.paginate(:page => 2, :per_page => 5, :order => "test_order ASC")
    assert_equal [[6,6], [7,7], [8,8], [9,9], [10,10]], ordinals2.map{|o| [o.test_order, o.ordinal_number] }
  end

end

class MoreOrdinal < ActiveRecord::Base
  acts_as_ordinalized

  named_scope :ordered, :order => "test_order ASC"
end

class OrdinalAssociationWithPaginationTest < Test::Unit::TestCase

  def setup
    setup_db
    ordinal = Ordinal.create!(:test_order => 0)
    (1..10).each { |counter| ordinal.more_ordinals.create!(:test_order => "#{counter}", :switch => counter.even?) }
  end

  def teardown
    teardown_db
  end

  def test_ordinal_associations_with_pagination
    ordinal = Ordinal.first
    ordinals2 = ordinal.more_ordinals.ordered.paginate(:page => 2, :per_page => 5)
    assert_equal [[6,6], [7,7], [8,8], [9,9], [10,10]], ordinals2.map{|o| [o.test_order, o.ordinal_number] }
    ordinals = ordinal.more_ordinals.ordered.paginate(:page => 1, :per_page => 5)
    assert_equal [[1,1], [2,2], [3,3], [4,4], [5,5]], ordinals.map{|o| [o.test_order, o.ordinal_number] }
  end

end
