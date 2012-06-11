# -*- encoding : utf-8 -*-
class Keyword < ActiveRecord::Base
  
  belongs_to :meta_term, :class_name => "MetaTerm"
  belongs_to :user
  belongs_to :meta_datum

  validates_presence_of :meta_term, :meta_datum

  default_scope :include => :meta_term

  def to_s
    "#{meta_term}"
  end
  
#######################################

  def self.search(query)
    return scoped unless query

    sql = select("DISTINCT keywords.*").joins(:meta_term)

    w = query.split.map do |x|
      "(%s)" % LANGUAGES.map do |l|
        if SQLHelper.adapter_is_mysql?
          "meta_terms.#{l} LIKE '%#{x}%'"
        elsif SQLHelper.adapter_is_postgresql?
          "meta_terms.#{l} ILIKE '%#{x}%'"
        else
          raise "this db adapter is not supported"
        end
      end.join(' OR ')
    end.join(' AND ')
    sql.where(w)
  end
  
end
