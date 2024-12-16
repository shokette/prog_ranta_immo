class GuidesController < ApplicationController

    def destroy
        @guide = Guide.find(params[:id])
        @guide.destroy
        redirect_to guides_path, notice: 'Guide supprimé avec succès.'
    end

    def index
        @guides = Guide.all
    end

    def new
        @guide = Guide.new
    end

    def edit
        @guide = Guide.find(params[:id])
    end

    def update
        @guide = Guide.find(params[:id])
        if @guide.update(guide_params)
            redirect_to guides_path, notice: 'Guide modifié avec succès.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def create
        @guide = Guide.new(guide_params)
        if @guide.save
            redirect_to guides_path, notice: 'Guide ajouté avec succès.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    private

    def guide_params
        params.require(:guide).permit(
            :name,
            :phone,
            :email
        )
    end
end