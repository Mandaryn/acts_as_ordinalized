require 'test/unit'

require 'rubygems'
gem 'activerecord'
require 'active_record'

require "#{File.dirname(__FILE__)}/../lib/acts_as_ordinalized"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :ordinals do |t|
      t.column :test_order, :integer
      t.column :switch, :boolean
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
end
begin
require 'will_paginate'
WillPaginate.enable_activerecord

class OrdinalWithPagination < ActiveRecord::Base
  acts_as_ordinalized
  set_table_name "ordinals"
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
    ordinals = OrdinalWithPagination.paginate(:page => 1, :per_page => 5, :order => "test_order ASC")
    assert_equal [[1,1], [2,2], [3,3], [4,4], [5,5]], ordinals.map{|o| [o.test_order, o.ordinal_number] }
    ordinals2 = OrdinalWithPagination.paginate(:page => 2, :per_page => 5, :order => "test_order ASC")
    assert_equal [[6,6], [7,7], [8,8], [9,9], [10,10]], ordinals2.map{|o| [o.test_order, o.ordinal_number] }
  end

end
rescue
end