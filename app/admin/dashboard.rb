ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do

    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do
      column do
        panel "System Info" do
          render partial: '../views/users/system_info'
        end
      end
    end
  end # content

  controller do
    def index
      pending_pay_ins_count = Payment.pay_in.pending.count
      pending_pay_ins_amount = helpers.number_with_precision(Payment.pay_in.pending.sum(:amount), precision: 2)
      pending_pay_outs_count = Payment.pay_out.pending.count
      pending_pay_outs_amount = helpers.number_with_precision(Payment.pay_out.pending.sum(:amount), precision: 2)
      root_created_at = User.root.order(:created_at).first&.created_at&.in_time_zone || Time.zone.now
      system_running_since = helpers.distance_of_time_in_words(Time.zone.now, root_created_at, include_seconds: true)
      @system_info = { total_member: User.count,
        pending_pay_ins_count: pending_pay_ins_count,
        pending_pay_ins_amount: pending_pay_ins_amount,
        pending_pay_outs_count: pending_pay_outs_count,
        pending_pay_outs_amount: pending_pay_outs_amount,
        system_running_since: system_running_since}
    end
  end
end
