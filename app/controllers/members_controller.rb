class MembersController < ApplicationController
    before_action :get_roles

    def destroy
        @member = Member.find(params[:id])
        @member.destroy
        redirect_to members_path, notice: 'Membre supprimé avec succès.'
    end

    def index
        @members = Member.all.includes(:role)
    end

    def new
        @member = Member.new
    end

    def edit
        @member = Member.find(params[:id])
    end

    def update
        @member = Member.find(params[:id])
        if @member.update(member_params)
            redirect_to members_path, notice: 'Membre modifié avec succès.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def create
        @member = Member.new(member_params)
        if @member.save
            redirect_to members_path, notice: 'Membe ajouté avec succès.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    private

    def get_roles
        @roles = Role.all
    end

    def member_params
        params.require(:member).permit(
            :name,
            :phone,
            :email,
            :role_id
        )
    end
end