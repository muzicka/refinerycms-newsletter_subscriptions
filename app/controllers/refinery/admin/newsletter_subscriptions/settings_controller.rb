module Refinery
  module Admin
    module NewsletterSubscriptions
      class SettingsController < Refinery::AdminController

        before_action :find_setting, :restrict_access, only: [:edit, :update]

        def update
          if @setting.update_attributes(setting_params)
            flash[:notice] = t('refinery.crudify.updated',
              kind: t(Refinery::Setting.model_name.i18n_key, scope: 'activerecord.models'),
              what: t(@setting.name, scope: 'refinery.admin.settings'))

            redirect_to refinery.edit_admin_newsletter_subscriptions_setting_path(@setting.slug,
              locale: params[:switch_frontend_locale].presence || Globalize.locale)
          else
            render :edit
          end
        end

      protected

        def find_setting
          case (id = params[:id].to_s)
          when 'confirmation_email'
            @setting = Refinery::NewsletterSubscriptions::ConfirmationEmailSetting.new
          else
            @setting = Refinery::Setting.find_by(name: id, scoping: 'newsletter_subscriptions')
          end

          @setting || error_404
        end

        def setting_params
          params.require(:setting).permit(:value, confirmation_email: [:subject, :message])
        end

        def restrict_access
          if @setting.restricted? && !current_refinery_user.has_role?(:superuser)
            error_403
          end
        end

      end
    end
  end
end
