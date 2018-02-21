#Created By: Amol Darekar
#Created Date:
#Purpose: This class contains code for Salesforce Operation
#Issue no:
require 'restforce'
require 'hashie'
require 'salesforce_bulk'
require 'json'

class Salesforce
  @@sfBulkClient = nil
  @@recordsMap = Hash.new
  @@recordsToDelete = Hash.new
  def initialize
    # security_token: '871hSV8y3j3nQDBtfYS113H6',
=begin
      @sfClient = Restforce.new(username: 'iamamol007@gmail.com',
                                          password: 'amol989080#',
                                          security_token: '1LLUAylBX5KcsZChaA2YMNfW',
                                          client_id: '3MVG9ZL0ppGP5UrAH8HwFC2kq8GsUoZ.RcsEqHoYcE4p2qKb.5p1SPlzpBejVESlSXikBYq7nHMFg8DOMJ5EX',
                                          grant_type:'refresh_token',
                                          client_secret: '6930647498837200879',
                                          api_version: '38.0')
=end
      @sfBulkClient = SalesforceBulk::Api.new('amol.darekar@wework.com.preprod','weworkamol@123Toni5TfNBLmZAzyBG5hKziwx4', true)
  end

  def createRecords(objectType,records_to_insert)
    recordIdsArray = Array.new
    @result = @sfBulkClient.create(objectType, records_to_insert,true)
    (@result.result.records).each_with_index do |object, index|
      recordIdsArray.push(Hash["Id" => (@result.result.records)[index]['Id']])
    end
    @@recordsToDelete.store(objectType,recordIdsArray)
    puts '@@recordsToDelete==>'
    puts @@recordsToDelete
    self.getRecords(objectType)
  end

  def getRecords(objectType)

    setIds = '('
    (@result.result.records).each_with_index do |object, index|
      setIds+='\''+(@result.result.records)[index]['Id'] +'\','
    end

    setIds = setIds.chomp(',')
    setIds+=')'

    @result = @sfBulkClient.query("Account","select Id, Name from Account where Id IN "+setIds+"")
    lstRecords = Array.new
    puts 'Get bulk data from salesforce sandbox==>'
    puts setIds
    self.putRecords(objectType,'Name')
  end

  def putRecords (outerMapKey,innerMapKey)
    sObjectRecordMap =Hash.new
    (@result.result.records).each_with_index do |object, index|
      puts ((@result.result.records[index]).to_hash)[innerMapKey]
      sObjectRecordMap.store(((@result.result.records[index]).to_hash)[innerMapKey],(@result.result.records[index]).to_hash)
    end
    @@recordsMap.store(outerMapKey,sObjectRecordMap)
    puts 'recordsMap==>'
    puts @@recordsMap
   # self.deleteRecords(outerMapKey)
  end

  def deleteRecords(sObjectType)
   deletedRecords = @sfBulkClient.delete(sObjectType, @@recordsToDelete['Lead'],true)
  end

end
