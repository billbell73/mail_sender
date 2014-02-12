require 'pg'
require 'date'
require 'net/smtp'
require 'mail'



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
    text_part do
      body "Here is your message from the past: #{row["message"]}
              Click link to see video: #{row["video_url"]}"
    end
    html_part do
      content_type 'text/html; charset=UTF-8'
      body '<b>Byeee!</b>'
    end
  end
end

conn = PG.connect( dbname: ENV['DATABASE_URL'] )
res = conn.exec("SELECT * FROM timecapsules")
res.each do |row| 
	date_past = Date.parse(row["send_at"]) < Date.today
  not_sent = row["sent"] == "f"
  if(date_past && not_sent)
    send_email(row)
  end
end





