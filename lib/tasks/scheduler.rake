require 'nokogiri'
require 'open-uri'
require 'nexmo'

desc "This gets all tweets, cleans them, and adds them to Accident - to be called by Heroku Scheduler"

task :get_tweets => :environment do
  
	def make_proper_array (nokoname, newname)
		nokoname.each do |x|
			newname.push(x.text)
		end
	end

	puts "Getting tweets..." 
	
	tweetsxml = Nokogiri::XML(open('https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=1310traffic'))
	#tweetsxml = Nokogiri::XML(open('https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=benjlcox'))
	
	rawstatus = tweetsxml.xpath("//status//text")
	rawid = tweetsxml.xpath("//status/id")
	
	cleanstatus = []
	cleanid = []
	counter = 0

	puts "Converting tweets..."

	make_proper_array(rawstatus, cleanstatus)
	make_proper_array(rawid, cleanid)

	puts "Cleaning tweets..."

	cleanstatus.each do |x|
		x.gsub!(/^.{9}/, "")
		x.gsub!(/\s[#].+$/, "")
		x[0] = x.first.capitalize[0]
	end

	puts "Merging tweets with ids..."

	cleaninfo = Hash[cleanid.zip(cleanstatus)]

	puts "Adding tweets to db..."

	cleaninfo.each do |k,v|
		if Accident.exists?(:tid => k) == false
			Accident.create(:tid => "#{k}", :details => "#{v}", :time => "Do this next")
		counter += 1
		end
		#puts "Key = #{k} and Value = #{v}"
		#puts "#{v}"
	end
	
	puts "Done. Records added: #{counter}"
end

desc "Search Accidents for streets in Users and alert the users via SMS"

task :alert_users => :environment do

	nexmo = Nexmo::Client.new('f45ec1ce', '460dfad4')
	accidents = Accident.find(:all, :conditions => { :sms_sent => false})
	users = User.find(:all)

	users.each do |user|
		
		user_streets = user.streets.split(",").map(&:to_s) #Loads the User's streets form the db, removes commas and makes them an array
		
		accidents.each do |accident|
			sauce = accident.details
			current_accident = Accident.find(accident.id) #these 3 lines can be a method
			if current_accident.sms_sent == false
				user_streets.each do |street|		
					if sauce.include?(street)
						puts "Send => #{accident.details} To => #{user.phone}"
						#nexmo.send_message!({:to => "#{user.phone}", :from => '16136270717', :text => "#{accident.details}"}) #should be using delayed job, should also be a method
						sleep 2 #replace this with delayed job
					end
				end
			end
		end
	end	
	
	accidents.each do |accident|
		accident.sms_sent = "true"
		accident.save
	end
end

task :reset_sms => :environment do
	accidents = Accident.find(:all)

	accidents.each do |accident|
		accident.sms_sent = "false"
		accident.save
	end
end
