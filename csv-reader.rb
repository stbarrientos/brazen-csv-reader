require 'csv'
require 'fileutils'
require 'trollop'

# CLI Interface
opts = Trollop::options do
  opt :source, "path/to/csv/file", type: :string, default:  "../corporate-gray-moaa-6-20141211-204645.csv"
  opt :destination, "path/to/destination/folder", type: :string, default: "headers-2014-12-12"
end


# Object to store all of the information for each applicant
class Applicant

  @@count = 0

  attr_reader :first_name, :last_name, :email, :street_address, :city, :state_province, :zipcode, :mil_branch, :mil_rank, :relocate, :date_available, :education_level, :clearance, :resume

  def initialize(first_name, last_name, email, street_address, city, state_province, zipcode, mil_branch, mil_rank, relocate, date_available, education_level, clearance, resume)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @street_address = street_address
    @city = city
    @state_province = state_province
    @zipcode = zipcode
    @mil_branch = mil_branch
    @mil_rank = mil_rank
    @relocate = relocate
    @date_available = date_available
    @education_level = education_level
    @clearance = clearance
    @resume = resume
    @@count += 1
  end

  # Access the count for file naming
  def self.count
    @@count
  end

  # How many zero's does the filename need
  def write_zeros
    total_digits = 8
    zeros = total_digits - (@@count.to_s.length)
  end
  
  # Method for file naming
  def file_name
    file_name = "h"
    write_zeros.times { file_name += "0" }
    file_name += @@count.to_s + ".txt"
  end

  # Make sure values are in quotes and nil values are empty strings
  def create_value(val)
    val ? "\"#{val}\"" : ""
  end

  # Create the new csv format in the proper order
  def create_file_string
    "#{create_value(@first_name)}, #{create_value(@last_name)}, #{create_value(@street_address)}, #{create_value(@city)}, #{create_value(@state_province)}, \"US\", #{create_value(@zipcode)}, \"\", #{create_value(@email)}, \"\", \"\", \"\", \"\", \"\", #{create_value(@mil_rank)}, #{create_value(@mil_branch)}, #{create_value(@clearance)}, #{create_value(@education_level)}, #{create_value(@relocate)}, #{create_value(@date_available)}"
  end

end

def write_files(source, destination)
  
  # Hash to convert from string representation to integer representation for rank from the csv file
  rank_values = {
    "E1" => 3,
    "E2" => 22,
    "E3" => 23,
    "E4" => 24,
    "E5" => 25,
    "E6" => 26,
    "E7" => 27,
    "E8" => 28,
    "E9" => 29,
    "W1" => 16,
    "W2" => 31,
    "W3" => 32,
    "W4" => 33,
    "W5" => 34,
    "O1" => 13,
    "O2" => 5,
    "O3" => 6,
    "O4" => 7,
    "O5" => 8,
    "O6" => 9,
    "O7" => 10,
    "O8" => 12,
    "O9" => 11,
    "010" => 35,
    "Civilian" => 37
  }

  # Hash to convert branch strings to branch integers
  branch_values = {
    nil => 0,
    "Unspecified" => 0,
    "Army" => 1,
    "Navy" => 2,
    "Air Force" => 3,
    "Marine Corps" => 4,
    "Coast Guard" => 5,
    "Army Reserve" => 6,
    "Navy Reserve" => 7,
    "Air Force Reserve" => 8,
    "Marine Corps Reserve" => 9,
    "Army National Guard" => 10,
    "Coast Guard Reserve" => 12,
    "Air National Guard" => 13,
    "Other" => 14
  }

  # Hash to convert clearance strings to integers
  clearance_values = {
    nil => 0,
    "Unspecified" => 0,
    "Secret" => 1,
    "Top Secret" => 2,
    "None" => 3
  }

  # Hash to convert education strings to integers
  education_values = {
    nil => 0,
    "Unspecified" => 0,
    "High School or GED" => 1,
    "Associates Degree" => 3,
    "Bachelors Degree" => 4,
    "Masters Degree" => 4,
    "PhD" => 4
  }
  # Go throught every row of the csv file
  CSV.foreach(source) do |row|

    # Store every column value of a row in an Application instance
    app = Applicant.new(
      row[0], # First name
      row[1], # Last name
      row[2], # Email
      row[11], # Street Address
      row[12], # City
      row[13], # State Province
      row[14], # Zipcode
      branch_values[row[17]], # Military Branch
      rank_values[row[18]], # Military Rank
      row[21] ? row[21].downcase : "", # Willing to Relocate, downcased
      row[22], # Date Available
      education_values[row[23]], # Education Level
      clearance_values[row[25]], # Clearance
      row[27], # Resume
    )

    # Write a new file and pass the csv contents to it
    new_file = File.open("#{destination}/#{app.file_name}", "w")
    new_file.write app.create_file_string
    new_file.close
  end
    puts "#{Applicant.count} files successfully created"
end

begin
  FileUtils.mkdir opts[:destination]
  write_files(opts[:source], opts[:destination])
rescue
  puts "Folder #{opts[:destination]} already exists, continue? (y/n)"
  continue = gets.chomp
  if continue == "y"
    write_files(opts[:source], opts[:destination])
  elsif continue == "n"
    puts "No files written. Exiting now..."
  else
    puts "Invalid selection, terminating program..."
  end
ensure
  puts "Done"
end
