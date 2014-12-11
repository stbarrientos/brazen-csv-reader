require 'csv'

class Applicant

   attr_reader :first_name, :last_name, :email, :date_created, :registered, :date_registration_updated, :attended, :peer_group, :job_id, :job_alias, :job_variant, :street_address, :city, :state_province, :zipcode, :age, :gender, :mil_branch, :mil_rank, :primary_mos, :mos_title, :relocate, :date_available, :education_level, :experience, :clearance, :polygraph, :resume, :profile_pic

  def initialize(first_name, last_name, email, date_created, registered, date_registration_updated, attended, peer_group, job_id, job_alias, job_variant, street_address, city, state_province, zipcode, age, gender, mil_branch, mil_rank, primary_mos, mos_title, relocate, date_available, education_level, experience, clearance, polygraph, resume, profile_pic)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @date_created = date_created
    @registered = registered
    @date_registration_updated = date_registration_updated
    @attended = attended
    @peer_group = peer_group
    @job_id = job_id
    @job_alias = job_alias
    @job_variant = job_variant
    @street_address = street_address
    @city = city
    @state_province = state_province
    @zipcode = zipcode
    @age = age
    @gender = gender
    @mil_branch = mil_branch
    @mil_rank = mil_rank
    @primary_mos = primary_mos
    @mos_title = mos_title
    @relocate = relocate
    @date_available = date_available
    @education_level = education_level
    @experience = experience
    @clearance = clearance
    @polygraph = polygraph
    @resume = resume
    @profile_pic = profile_pic
  end

end

# Store all of the applicant objects
applicant_array = []

# Go throught every row of the csv file
CSV.foreach("../corporate-gray-moaa-6-20141211-204645.csv") do |row|

  # Store every column value of a row in an Application instance
  app = Applicant.new(
    row[0], # First name
    row[1], # Last name
    row[2], # Email
    row[3], # Date Created
    row[4], # Registered
    row[5], # Date Registration Last Updated
    row[6], # Attended
    row[7], # Peer Group
    row[8], # Job Id
    row[9], # Job Alias
    row[10], # Job Variant
    row[11], # Street Address
    row[12], # City
    row[13], # State Province
    row[14], # Zipcode
    row[15], # Age
    row[16], # Gender
    row[17], # Military Branch
    row[18], # Military Rank
    row[19], # Primary MOS
    row[20], # MOS Title
    row[21], # Willing to Relocate
    row[22], # Date Available
    row[23], # Education Level
    row[24], # Experience
    row[25], # Clearance
    row[26], # Polygraph
    row[27], # Resume
    row[28] # Profile Picture
  )

  # Add the new Application instance to the applicant_array 
  applicant_array << app
end

puts applicant_array.length
