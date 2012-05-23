# -*- encoding : utf-8 -*-
 
class MetaDatumDate < MetaDatum

  alias_attribute :value, :string

  after_save do
    SQLHelper.execute_sql "UPDATE meta_data SET value = NULL where id = #{id}"
  end

  def set_value_before_save
  end

  def to_s
    string
  end

end
