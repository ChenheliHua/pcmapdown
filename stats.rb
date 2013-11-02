# Parameter: a user's OSM display name
# Response: Number of modifiations a user has done
def user_stats(name,start_time,end_time)
  # Add gem
  require 'net/http'
  require 'rexml/document'

  # Call OSM changeset api
  url = 'http://www.openstreetmap.org/api/0.6/changesets?display_name=' + name
  resp = Net::HTTP.get_response(URI.parse(url))

  # Extract and parse XML data
  data = resp.body
  doc = REXML::Document.new(data)
  
  # Collect all changeset ids
  changeset_ids = []

  doc.elements.each('osm/changeset') do |cs|
    # Parse the time of the changeset
    time = Date.parse(cs.attributes['created_at'])
    
    if((time>=start_time)&&(time<=end_time))
      changeset_ids << cs.attributes['id']
    end
  end

  # Record contributions
  contribution = 0

  # Loop over each change set
  changeset_ids.each do |id|
    # Get data for each changeset
    url = 'http://www.openstreetmap.org/api/0.6/changeset/'+id+'/download'
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body

    # Parse changeset data
    doc = REXML::Document.new(data)
    
    tags = 0
    
    # Add to contribution
    #contribution += doc.elements['osmChange'].size
    doc.elements['osmChange'].each do |ele|
      tags += 1
    end

    # A hack to get correct number of immediate subtags of osmChange
    # due to unknown parsing behavior of REXML
    if tags>0
      tags = ((tags - 1)/2)
    end
    
    # Added to total contribution
    contribution += tags
    
  end

  # Return
  contribution
end

# Time period to collect data
# Parse format DD/MM/YYYY
start_time = Date.parse('23/10/2013')
end_time = Date.today #Date.parse('23/10/2013')

users = [
         'shazzie',
'Choquette33',
'iusoccer13',
'mjnormil',
'VanuatuGwen',
'kg_arm',
'Ninayeni',
'Mbigou',
'vtcraghead',
'sedgwica',
'cars0068',
'to_d',
'jmulqueen',
'annie89pease',
'thadk',
'Tom-AZ',
'kcoughlin',
'kdbah',
'Patrick%20Welsh',
'sunkaru',
'housh8',
'danbjoseph',
'jessicaluo',
'edeo',
'linfieldjosh',
'chrisarrr',
'm_full',
'Tova',
'BansangMolu',
'GWstudent007',
'agvelarde',
'kokobutts',
'gkrieshok',
'sizlars',
'mkennedy_g@yahoo.com',
'Ashley13aj',
'zosima',
'KBM',
'AzFaith',
'compassrose',
'zachs',
'bamba',
'astogner',
'girlfawkes',
'ABigApple',
'Kwame%20Aboagye',
'joeloula',
'K%20Vee',
'bethanybdavidson',
'zqfmgb',
'kmccormack',
'slanning'

        ] # List of OpenStreetMap usernames. For privacy, delete the list after the data is collected. 

f = File.open('data.csv','w')

users.each_with_index do |user,index|
  f.write(user)
  if(index!=(users.size-1))
    f.write(',')
  end
end

f.write("\n")

users.each_with_index do |user,index|
  puts user
  f.write(user_stats(user,start_time,end_time))

  if(index!=(users.size-1))
    f.write(',')
  end
end
