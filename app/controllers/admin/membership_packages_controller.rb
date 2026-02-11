module Admin
  class MembershipPackagesController < BaseController
    before_action :set_package, only: %i[edit update]

    def index
      # Usamos includes para evitar N+1 queries al cargar los tipos de clase
      @packages = MembershipPackage.includes(:class_types).order(:name)
    end

    def new
      @membership_package = MembershipPackage.new(active: true)
    end

    def create
      @membership_package = MembershipPackage.new(package_params)
      
      if @membership_package.save
        redirect_to admin_membership_packages_path, notice: t('admin.packages.flash.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @membership_package.update(package_params)
        redirect_to admin_membership_packages_path, notice: t('admin.packages.flash.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_package
      @membership_package = MembershipPackage.find(params[:id])
    end

    def package_params
      params.require(:membership_package).permit(:name, :description, :price_modifier, :active, class_type_ids: [])
    end
  end
end