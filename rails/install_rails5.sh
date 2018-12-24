#!/bin/bash
# install_rails5.sh
#
# very simple activ_admin sample, using sqlite3.

sudo apt-get update
sudo apt-get install -y ruby sqlite3 libsqlite3-dev
sudo apt-get install -y build-essential liblzma-dev patch ruby-dev zlib1g-dev
sudo gem install rails

APPNAME="myapp"
rails new $APPNAME

cd $APPNAME
cat <<EOF >> Gemfile
gem 'devise'
gem 'activeadmin'
gem 'therubyracer'
EOF

bundle install
bin/rails g active_admin:install --skip-users &
sleep 2
bin/rails g active_admin:install AdminAccount &
sleep 2


sed -e 's/^end/  config.action_mailer.default_url_options = { host: \"localhost\", port: 3000 }\nend/g' \
  config/environments/development.rb > config/environments/development.rb.after

mv -f config/environments/development.rb.after config/environments/development.rb


sed -e 's/^end/  root to: \"home#index\" \nend/g' \
  config/routes.rb > config/routes.rb.after
  
mv -f config/routes.rb.after config/routes.rb


cat <<EOF >> app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>$APPNAME</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>
  <body>
    <header>
      <nav>
        <% if user_signed_in? %>
          <%= link_to 'edit user' , edit_user_registration_path %>
          <%= link_to 'logout', destroy_user_session_path, method: :delete %>
        <% else %>
          <%= link_to 'sign up', new_user_registration_path %>
          <%= link_to 'login', new_user_session_path %>
        <% end %>
      </nav>
    </header>
    <p class="notice"><%= notice %></p>
    <p class="alert"><%= alert %></p>
    <%= yield %>
  </body>
</html>
EOF


bin/rails g devise:views

sed -e 's/[ ]*\#[ ]*config.default_namespace = :hello_world/  config.default_namespace = :admin_login/g'  \
  config/initializers/active_admin.rb > config/initializers/active_admin.rb.after
  
mv -f config/initializers/active_admin.rb.after config/initializers/active_admin.rb


bin/rails g devise User
bin/rails g model Role name:string detail:string
bin/rails g model Profile name:string user:references role:references


bin/rake db:migrate
bin/rake db:seed


bin/rails g controller home index

cat <<EOF >> app/views/home/index.html.erb
<h1>Home#index</h1>
<p>Find me in app/views/home/index.html.erb</p>
<%= link_to 'admin console', new_admin_account_session_path %>
EOF


bin/rails g active_admin:resource Role
bin/rails g active_admin:resource User
bin/rails g active_admin:resource Profile


cat <<EOF >> app/admin/users.rb
ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation
  index do
    selectable_column
    id_column
    column :email
    column :created_at
    actions
  end
  filter :email
  filter :created_at
  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
EOF


cat <<EOF >> app/admin/roles.rb
ActiveAdmin.register Role do
  permit_params :name, :detail
end
EOF


cat <<EOF >> app/admin/profiles.rb
ActiveAdmin.register Profile do
  permit_params :name , :user_id , :role_id
  form do |f|
    f.inputs do
      f.input :name
      f.input :user , :member_label => :email , as: :select
      f.input :role , :member_label => :name  , as: :select
    end
    f.actions
  end
end
EOF


bin/rails s -b 0.0.0.0

# end
