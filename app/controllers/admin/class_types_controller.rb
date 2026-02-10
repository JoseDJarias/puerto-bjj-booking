module Admin
  class ClassTypesController < BaseController
    before_action :set_class_type, only: %i[edit update]

    def index
      #Ordered by name for visual consistency
      @class_types = ClassType.order(:name)
    end

    def new
      @class_type = ClassType.new(active: true)
    end

    def create
      @class_type = ClassType.new(class_type_params)

      if @class_type.save
        redirect_to admin_class_types_path, notice: t('admin.class_types.flash.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @class_type.update(class_type_params)
        redirect_to admin_class_types_path, notice: t('admin.class_types.flash.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_class_type
      @class_type = ClassType.find(params[:id])
    end

    def class_type_params
      params.require(:class_type).permit(:name, :description, :active)
    end
  end
end