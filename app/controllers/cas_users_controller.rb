class CasUsersController < ApplicationController
  before_action :set_cas_user, only: %i[show show_history edit update destroy]
  before_action :verify_admin, only: %i[index new create edit update destroy]
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
    #byebug
    @days = params.key?(:days) ? params[:days].to_i : 90
    @events = audit_events_for_user(@cas_user.cas_directory_id, @days)
  end

  def audit_events(filter, bindings)
    offset = bindings.delete(:offset)
    limit = bindings.delete(:limit)
    short_name_for = {
      'http://id.loc.gov/vocabulary/preservation/eventType/cre' => 'Create Resource',
      'http://id.loc.gov/vocabulary/preservation/eventType/ing' => 'Ingest Resource',
      'http://fedora.info/definitions/v4/audit#metadataModification' => 'Metadata Modification',
      'http://fedora.info/definitions/v4/audit#contentRemoval' => 'Content Removal',
      'http://id.loc.gov/vocabulary/preservation/eventType/del' => 'Delete Resource'
    }
    sparql = SPARQL::Client.new(Rails.configuration.audit_sparql_endpoint)
    premis = RDF::Vocabulary.new('http://www.loc.gov/premis/rdf/v1#')
    query = sparql.select(:event, :agent, :resource, :timestamp, :type)
      .prefix(xsd: RDF::URI('http://www.w3.org/2001/XMLSchema#'))
      .where(
        [:event, premis.hasEventRelatedAgent, :agent],
        [:event, premis.hasEventRelatedObject, :resource],
        [:event, premis.hasEventDateTime, :timestamp],
        [:event, premis.hasEventType, :type],
      )
      .filter(filter)
      .order(timestamp: :desc)
      .values(bindings.keys, bindings.values)

    query = query.offset(offset) unless offset.nil?
    query = query.limit(limit) unless limit.nil?

    query.each_solution.map(&:to_h).each do |event|
      type_uri = event[:type].to_s
      event[:type_description] = short_name_for.key?(type_uri) ? short_name_for[type_uri] : type_uri
    end
  end

  def audit_events_for_user(username, days_back)
    audit_events '?timestamp > xsd:dateTime(?oldest) && ?agent = ?user',
      user: username,
      oldest: (DateTime.now - days_back.days).to_s
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
