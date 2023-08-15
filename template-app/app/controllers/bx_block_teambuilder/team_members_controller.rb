module BxBlockTeambuilder
  class TeamMembersController < ApplicationController
    include BuilderJsonWebToken::JsonWebTokenValidation

    before_action :set_team_member, only: %i[show update destroy]
    before_action :validate_json_web_token

    def index
      employees = current_user&.employees
      render json: TeamMemberSerializer.new(employees), status: :ok
    end

    def create
      team_member = current_user.employees.new(team_member_params)

      if team_member.save
        render json: {
          message: 'team member successfully created',
          team_member: TeamMemberSerializer.new(team_member)
        }, status: :created
      else
        render json: { errors: format_activerecord_errors(team_member&.errors) }, status: :unprocessable_entity
      end
    end

    def show
      render json: TeamMemberSerializer.new(@team_member), status: :ok
    end

    def update
      @team_member.update(team_member_params)
      render json: TeamMemberSerializer.new(@team_member), status: :ok
    end

    def destroy
      @team_member.destroy
      render json: { success: true }, status: :ok
    end

    private

    def set_team_member
      @team_member = BxBlockTeambuilder::TeamMember.find_by(id: params[:id])

      if @team_member.nil?
        render json: {
          message: "team_member with id #{params[:id]} doesn't exists"
        }, status: :not_found
      end
    end

    def format_activerecord_errors(errors)
      result = []
        errors.each do |attribute, error|
          result << { message: "#{attribute} #{error}" }
        end
      result
    end

    def team_member_params
      params.require(:data).permit(:name, :email, :image)
    end
  end
end