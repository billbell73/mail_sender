require 'pg'
require 'date'
require 'mail'
require 'uri'


Mail.defaults do
  delivery_method :smtp, {
    :address => 'smtp.sendgrid.net',
    :port => '587',
    :domain => 'heroku.com',
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end


def send_email(row)
  mail = Mail.deliver do
    to row["email"]
    from 'Your Name <name@domain.com>'
    subject 'Time capsule!!'
    # text_part do
    #   body "Hello"     
    # end
    html_part do
      content_type 'text/html; charset=UTF-8'
      body "<p>Your message from the past: #{row["message"]}</p>" +
            "<p>Click link to see video: #{row["video_url"]}</p>"
    end
  end
end


uri = URI.parse(URI.encode(ENV['DATABASE_URL']))

conn = PG.connect(:dbname => uri.path[1..-1], 
                  :user => uri.user, 
                  :password => uri.password, 
                  :host => uri.host, 
                  :port => uri.port)

res = conn.exec("SELECT * FROM timecapsules 
                  WHERE sent = false 
                  AND send_at <= current_date")

res.each do |row| 
  send_email(row)
end





