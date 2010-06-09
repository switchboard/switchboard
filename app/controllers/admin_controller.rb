class AdminController < ApplicationController

  helper 'admin'

  def show_members
    list = List.find(params[:list_id])
    numbers = list.phone_numbers
    #select_html = collection_select(nil, nil, list.members, :id, :name, {}, {:multiple => 1, :size => 20})
    render :update do |page|
      if numbers.empty?
        page.replace_html 'show_member_list', 'No members to display'
      else 
        page.replace_html 'member_list', :partial => '/admin/member', :collection => numbers 
      end
      page.replace 'hidden_list_id', hidden_field_tag('user[list_id]', list.id, :id => 'hidden_list_id')
    end
  end

  def add_member
    ps = params[:user]
    list = List.find(ps.delete('list_id'))
    phone = PhoneNumber.create!(:number => ps.delete('phone'))
    user = User.create!(ps)
    user.phone_numbers << phone
    list.add_phone_number(phone, user)
    redirect_to :action => 'show_members', :controller => 'admin', :params => {:list_id => list.id}
  end

  def view_member
  end

end
