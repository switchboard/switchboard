module AdminHelper

  def select_list
    collection_select(nil, nil, List.find(:all), :id, :name, {}, {:multiple => 1, :size => 20})  
  end

end
