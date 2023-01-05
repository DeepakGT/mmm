ActiveAdmin.register Support::Ticket do
  actions :all, except: :new

  permit_params :status

  form do |f|
    f.semantic_errors *f.object.errors.keys
    inputs 'Resolve the ticket' do
      input :status, include_blank: false
    end
    actions
  end
end