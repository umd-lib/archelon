# frozen_string_literal: true

class CasUsersController < ApplicationController
  before_action :set_cas_user, only: %i[show show_history destroy]
  before_action :verify_admin, only: %i[index destroy]
  before_action :verify_self_or_admin, only: %i[show show_history]

  # GET /cas_users
  # GET /cas_users.json
  def index
    @cas_users = CasUser.all
  end

  # GET /cas_users/1
  # GET /cas_users/1.json
  def show
  end

  def show_history
    @days = params.key?(:days) ? params[:days].to_i : 90
    @events = audit_events_for_user(@cas_user.cas_directory_id, @days)
  end

  def audit_events(bindings) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    short_name_for = {
      'http://id.loc.gov/vocabulary/preservation/eventType/cre' => 'Create Resource',
      'http://id.loc.gov/vocabulary/preservation/eventType/ing' => 'Ingest Resource',
      'http://fedora.info/definitions/v4/audit#metadataModification' => 'Metadata Modification',
      'http://fedora.info/definitions/v4/audit#contentRemoval' => 'Content Removal',
      'http://id.loc.gov/vocabulary/preservation/eventType/del' => 'Delete Resource'
    }

    history_query = <<-END
      SELECT
        timestamp,
        event_type,
        resource_uri,
        to_char(timestamp, 'YYYY-MM-DD') as date,
        to_char(timestamp, 'FMHH:MI:SS am TZ') as time
      FROM history
      WHERE username = $1 AND timestamp > $2
      ORDER BY timestamp DESC
    END

    # TODO: put the connection setup somewhere central
    conn = PG.connect(Rails.configuration.audit_database)

    # the TZ environment variable overrides the default time zone
    tz = ENV.key?('TZ') ? ENV['TZ'] : Time.zone.name
    conn.exec("SET timezone = '#{conn.escape(tz)}'")

    conn.exec_params(history_query, [bindings[:user], bindings[:oldest]]) do |result|
      result.map do |row|
        {
          date: row['date'],
          time: row['time'],
          timestamp: row['timestamp'],
          type: row['event_type'],
          type_description: short_name_for[row['event_type']],
          resource: row['resource_uri']
        }
      end
    end
  end

  def audit_events_for_user(username, days_back)
    audit_events user: username, oldest: (DateTime.now - days_back.days).to_s
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
