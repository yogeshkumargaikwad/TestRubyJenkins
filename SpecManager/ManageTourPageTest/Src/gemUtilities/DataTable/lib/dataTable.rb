class DataTable
	def getHeaders
		EnziUIUtility.wait(@driver,nil,nil,60)
		EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",100)
	    arrTable = @driver.find_elements(:id,'enzi-data-table-container')
	    mapOfDataOnEachPage=nil
	    #mapOfDataOnEachPageHashMap=Hash.new

	    arrTable.each do|table|
	      	if table.attribute('tag_name') != 'table' then
	        	mapOfDataOnEachPage = table
	      	end
    	end
	   	#puts "mapOfDataOnEachPage #{mapOfDataOnEachPage}"

	    tHeadEle = mapOfDataOnEachPage.find_element(:tag_name,'thead')
	    rowOfHeaders = tHeadEle.find_elements(:tag_name,'tr')
	    arrHeaders = Array.new
		#puts rowOfHeaders.length
		#puts rowOfHeaders[0].find_elements(:tag_name,'th').length
	    rowOfHeaders.each do |row|
	    	#puts "row found"
	      	row.find_elements(:tag_name,'th').each do |col|
	      		#puts "col found"
	      		#puts "111"+col.text
	      		if col.text.include?("Sort") == true
		      		header=col.text
		      		header=header.delete("\n")
		      		header=header.split("Sort")[1]
		      		#puts "111111111111111111"+header
		      		arrHeaders.push(header.chomp)
		      	else
		      			#puts "222222222222222222"+col.text
		      			arrHeaders.push(col.text.chomp)
		      	end
	  		end
	    end #end of rowOfHeaders.each
	    #puts "1111111#{arrHeaders}"
	    #puts "2222222#{arrHeaders[0]}"
	    #puts "333333#{arrHeaders}"
	    #puts "1111111#{arrHeaders[2]}"
	    return arrHeaders
	end

    def getAllData(onlySelected)
    	#totalRowCount = 0
    	pageNumber = 1
    	mapOfAllData = Hash.new
    	clickElement("btnFirst")
		loop do 
			mapOfDataOnEachPage = getData(onlySelected)
			#puts mapOfDataOnEachPage
		    #totalRowCount += rowCount
		    #puts rowCount
		    #puts totalRowCount
		    #puts pageNumber
		    if mapOfDataOnEachPage != nil then
		   		mapOfAllData.store("#{pageNumber}",mapOfDataOnEachPage)
		   	end
		    #puts mapOfAllData
		    pageNumber += 1
	  		break if clickElement("btnNext") == false
		end 
		#puts mapOfAllData
		return mapOfAllData

    end

	def getData(onlySelected)
		EnziUIUtility.wait(@driver,nil,nil,20)
		EnziUIUtility.wait(@driver,:id,"enzi-data-table-container",100)
	    arrTable = @driver.find_elements(:id,'enzi-data-table-container')	    
	    mapOfDataOnEachPage=nil
	    mapOfDataOnEachPageHashMap=Hash.new
	    arrTable.each do|table|
	      	if table.attribute('tag_name') != 'table' then
	        	mapOfDataOnEachPage = table
	      	end
    	end
	   	tBodyEle = mapOfDataOnEachPage.find_element(:tag_name,'tbody')
	    arrRows = tBodyEle.find_elements(:tag_name,'tr')
	    totalRows=tBodyEle.find_elements(:tag_name,'tr').length
	    totalRows -= 1
	    rowCount=0
	    if onlySelected == true then
	    	arrRows.each do |row|
		    	#puts "in selected row"
		    	#puts "checkbox:#{rowCount}"
		    	#puts rowCount
		    	#puts totalRows
		    	if rowCount == totalRows then
		    		break
		    	end
		    	isRowSelected= @driver.find_element(:id,"checkbox:#{rowCount}").selected?
		    	if isRowSelected == true then
			    	arr = Array.new
			    	row.find_elements(:tag_name,'td').each do |col|
			    		#puts "col"
			    		if col.text == "Select Row" then
			    			#puts col.text
			    			arr.push(isRowSelected)
			    		else
			    			#puts col.text
			    			arr.push(col.text)
			    		end
			        end
		        	mapOfDataOnEachPageHashMap.store("#{rowCount}",arr)
		    	end
		    	rowCount = rowCount + 1
		    end
	    else
		    arrRows.each do |row|
			    if rowCount == totalRows then
			    	break
			    end
			    isRowSelected= @driver.find_element(:id,"checkbox:#{rowCount}").selected?
			    #puts "row"
			    arr = Array.new
			    row.find_elements(:tag_name,'td').each do |col|
				    #puts "col"
				    #puts col.text
				    arr.push(col.text)
		    	end
		        mapOfDataOnEachPageHashMap.store("#{rowCount}",arr)
		        rowCount = rowCount + 1
		    end
		end
		#puts mapOfDataOnEachPageHashMap
		return mapOfDataOnEachPageHashMap
	end
end