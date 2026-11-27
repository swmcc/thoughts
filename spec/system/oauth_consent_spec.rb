require "rails_helper"

RSpec.describe "OAuth consent", type: :system do
  let!(:admin) { create(:admin_user, password: "password123", password_confirmation: "password123") }

  # The app is served on 127.0.0.1; a localhost callback is a different
  # origin, like claude.ai is in production.
  def callback_uri
    "http://localhost:#{Capybara.current_session.server.port}/oauth-callback"
  end

  def start_authorization(client)
    _, challenge = pkce_pair
    visit oauth_authorize_path(authorize_params(client, challenge, redirect_uri: callback_uri))
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Sign in"
    expect(page).to have_content("Connect Claude?")
  end

  def register
    visit root_path # boots the server so its port is known
    Oauth::Client.register(client_name: "Claude", redirect_uris: [ callback_uri ]).first
  end

  it "redirects to the client's callback with a code when Allow is clicked" do
    start_authorization(register)

    click_button "Allow"

    expect(page).to have_current_path(%r{\A/oauth-callback\?}, url: false)
    query = Rack::Utils.parse_query(URI.parse(page.current_url).query)
    expect(URI.parse(page.current_url).host).to eq("localhost")
    expect(query["code"]).to be_present
    expect(query["state"]).to eq("xyz")
  end

  it "redirects with access_denied when Deny is clicked" do
    start_authorization(register)

    click_button "Deny"

    expect(page).to have_current_path(/error=access_denied/)
  end
end
