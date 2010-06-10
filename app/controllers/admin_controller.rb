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
      page.hide 'flash_messages_container'
    end
  end

  def add_member
    ps = params[:user]
    @list = List.find(ps.delete('list_id'))
    @phone = PhoneNumber.create(:number => ps.delete('phone'))
    @user = User.create(ps)
    if @phone.save and @user.save
      @list.add_phone_number(phone, user)
      user.phone_numbers << phone
      redirect_to :action => 'show_members', :controller => 'admin', :params => {:list_id => list.id}
    else
      # if this were ever able to be called as a regular POST and not an xhr request
      # then we'd want to use respond_to do |format| instead of this.
      render :update do |page|
        page.replace_html 'flash_messages_container', :partial => '/layouts/flash_errors', :locals => {:objects => [@phone, @user]}
        page.show 'flash_messages_container'
      end
    end
  end

  def view_member
  end

end
