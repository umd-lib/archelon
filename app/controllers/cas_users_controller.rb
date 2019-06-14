class CasUsersController < ApplicationController
  before_action :set_cas_user, only: %i[show edit update destroy]
  before_action :verify_admin, only: %i[index new create edit update destroy]
  before_action :verify_self_or_admin, only: [:show]

  # GET /cas_users
  # GET /cas_users.json
  def index
    @cas_users = CasUser.all
  end

  # GET /cas_users/1
  # GET /cas_users/1.json
  def show
  end

  # DELETE /cas_users/1
  # DELETE /cas_users/1.json
  def destroy
    @cas_user.destroy
    respond_to do |format|
      format.html { redirect_to cas_users_url, notice: 'Cas user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_cas_user
      @cas_user = CasUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cas_user_params
      params.require(:cas_user).permit(:cas_directory_id, :name, :admin)
    end

    # Verify current user is an admin before all actions except :show
    def verify_admin
      return if current_cas_user.admin?
      render(file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false)
    end

    # Verify current user is an admin before all actions except :show
    def verify_self_or_admin
      return unless !current_cas_user.admin? && (current_cas_user.id != @cas_user.id)
      render(file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false)
    end
end
