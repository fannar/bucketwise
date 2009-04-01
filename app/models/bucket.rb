class Bucket < ActiveRecord::Base
  DEFAULT_PAGE_SIZE = 100

  Temp = Struct.new(:id, :name, :role, :balance)

  belongs_to :account
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"

  has_many :line_items do
    def page(n, options={})
      size = options.fetch(:size, DEFAULT_PAGE_SIZE)
      records = find(:all, :include => { :event => :line_items },
        :order => "occurred_on DESC",
        :limit => size + 1,
        :offset => n * size)

      [records.length > size, records[0,size]]
    end
  end

  def self.default
    Temp.new("r:default", "General", "default", 0)
  end

  def self.aside
    Temp.new("r:aside", "Aside", "aside", 0)
  end

  def balance
    @balance ||= line_items.sum(:amount) || 0
  end
end
