# add benchmarking
unless Rails.env.production?
  require 'capybara/poltergeist'
  require 'faker'

  class LoadTest
    include Capybara::DSL
    attr_reader :host

    def initialize(server_url = nil)
      @host = server_url
    end

    def host
      @host ||= 'http://scale-up-time.herokuapp.com'
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      while true do
        send(user_actions.sample)
      end
    end

    def user_actions
      [:anon_user_browses_requests,
        :view_loan_request,
        :sign_up_as_lender,
        :sign_up_as_borrower,
        :browse_categories,
        :lender_makes_loan,
        :borrower_creates_loan_request,
        :browse_pages_of_loan_requests,
        :browse_pages_of_categories]
    end

    def anon_user_browses_requests
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
      puts "Currently browsing #{session.current_path}"
    end

    def browse_pages_of_loan_requests
      log_in
      session.visit "#{host}/browse?page=#{rand(5000)}"
      puts "Currently viewing loan request page at #{session.current_path}"
    end

    def view_loan_request
      log_in
      session.visit "#{host}/browse"
      session.all('a.btn.btn-default.lr-about').sample.click
      puts "Currently viewing loan request at #{session.current_path}"
    end

    def browse_categories
      log_in
      session.visit "#{host}/browse"
      session.visit "#{host}/browse?category=#{categories.sample}"
      puts "Currently viewing category at #{session.current_path}"
    end

    def browse_pages_of_categories
      log_in
      session.visit "#{host}/categories/#{rand(Category.all.count)}/?page=#{rand(1500)}"
      puts "Currently visiting category page at #{session.current_path}"
    end

    def borrower_creates_loan_request
      sign_up_as_borrower
      session.click_link "Create Loan Request"
      session.fill_in "Title", with: "Title #{Time.now.to_i}"
      session.fill_in "Description", with: "Description #{Time.now.to_i}"
      session.fill_in "Requested by date", with: "#{Time.now.strftime("%m/%d/%Y")}"
      session.fill_in "Repayment begin date", with: "#{Time.now.strftime("%m/%d/%Y")}"
      session.fill_in "Amount", with: "#{rand(100..5000)}"
      session.click_button "Submit"
      puts "Successfully created loan request"
    end

    def lender_makes_loan
      sign_up_as_lender
      session.visit "#{host}/loan_requests/#{rand(200)}"
      session.click_on("Contribute $25")
      session.click_on("Basket")
      session.click_on("Transfer Funds")
      puts "Successfully funded project"
    end

    def borrower_visits_portfolio
      sign_up_as_borrower
      session.visit "#{host}/portfolio"
      puts "Successfully visited borrower portfolio"
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def sign_up_as_lender
      sign_up_as('lender', new_user_name)
    end

    def sign_up_as_borrower
      sign_up_as('borrower', new_user_name)
    end

    def sign_up_as(role, name)
      session.visit host
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-#{role}").click
      session.within("##{role}SignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
      puts "Successfully signed up as a new #{role}, #{name}"
    end

    def log_in
      session.visit host
      session.click_link 'Login'
      session.fill_in 'Email', with: 'horace@example.com'
      session.fill_in 'Password', with: 'password'
      session.click_on 'Log In'
      puts "Successfully logged in"
    end

    def log_out
      if session.has_content?("Log out")
        session.click_link "Log out"
        puts "Successfully logged out"
      end
    end

    def categories
      ["Agriculture",
        "Education",
        "Water and Sanitation",
        "Youth",
        "Conflict Zones",
        "Transportation",
        "Housing",
        "Banking and Finance",
        "Manufacturing",
        "Food and Nutrition",
        "Vulnerable Groups"]
    end
  end

  namespace :load_test do
    desc "Simulate load against Keevah application"
    task :run => :environment do
      6.times.map { Thread.new { LoadTest.new.run } }.map(&:join)
    end
  end
end
