require 'salesforce_bulk'

class Salesforce
	@sfBulk = nil
  def initialize()
    #puts @driver.title
  end

	def self.login(username,password,isSandbox)
		sfBulk =  SalesforceBulk::Api.new(username, password, isSandbox)
		#puts 'sfBulk==>'
		#puts sfBulk
		return sfBulk
	end


  def self.getRecords(sfBulk,sObjectType,query,key = nil)
    result =nil
    sObjectRecordMap = nil
    result = sfBulk.query(sObjectType,query)
    
    if key == nil then
      
      return result
    else  
      sObjectRecordMap = Hash.new
      (result.result.records).each_with_index do |object, index|
          sObjectRecordMap.store(((result.result.records[index]).to_hash)[key],(result.result.records[index]).to_hash)
      end
      return sObjectRecordMap
    end
  end

 def self.createRecords(sfBulk,objectType,records_to_insert)
    recordIdsArray = Array.new
    result = sfBulk.create(objectType, records_to_insert,true)
    (result.result.records).each_with_index do |object, index|
        recordIdsArray.push(Hash["Id" => (result.result.records)[index]['Id']])
    end
    #puts 'Created Records ==>'
    return recordIdsArray
 end

 def self.getCreatedRecords(sfBulk,objectType,query,recordIds)
    setIds = nil
    setIds = '('

    (recordIds).each_with_index do |object, index|
    setIds+='\''+(recordIds)[index]['Id'] +'\','
    end
    setIds = setIds.chomp(',')
    setIds+=')'
    #puts 'query in createdrRecords==>'
    #puts query+" Id IN "+setIds+""
    result = sfBulk.query(objectType, query+" WHERE Id IN "+setIds+"")
    #puts 'result.result.records==>'
    #puts result.result.records
    return result.result.records
 end

 def self.deleteRecords(sfBulk,sObjectType,recordsToDelete)
  if(recordsToDelete!= nil && recordsToDelete.count > 0 && recordsToDelete.count < 5) 
     deletedRecords = sfBulk.delete(sObjectType, recordsToDelete,true)
     #puts 'deletedRecords==>'
     #puts deletedRecords
     return deletedRecords.result.records
  else
    return nil
  end
end
end