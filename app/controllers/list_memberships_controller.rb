class ListMembershipsController < ApplicationController
  def destroy
    # FIXME a user can delete any membership, even not her own
    lm = ListMembership.find(params[:id])

    respond_to do |format|
      format.js do
        if lm.destroy
          head :ok
        else
          head :internal_server_error
        end
      end
    end
  end
end
