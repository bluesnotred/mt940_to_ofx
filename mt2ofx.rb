#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'digest/sha1'
require 'mt940'
require 'date'
require 'builder'
require 'base64'

file_name = ARGV[0]

exit if file_name.nil? || !File.file?(file_name)

@parse_result = MT940Structured::Parser.parse_mt940(file_name)
@accountnr = @parse_result.keys[0]
@bankname =  @parse_result.values.first.first.transactions.first.bank
@date1 = @parse_result.values.first.first.transactions.first.date
@date2 = @parse_result.values.last.last.transactions.last.date

if @date1 < @date2
  @startdate = @date1
  @enddate = @date2
else
  @startdate = @date2
  @enddate = @date1
end    

puts "Start: #{@startdate}"
puts "End: #{@enddate}"
puts "Account: #{@accountnr}"
puts "Bankname: #{@bankname}"

buffer = ""
    b = Builder::XmlMarkup.new(:target=>buffer, :indent=>2)
    b.instruct!
      
    b << "<?OFX OFXHEADER=\"200\" VERSION=\"200\" SECURITY=\"NONE\" OLDFILEUID=\"NONE\" NEWFILEUID=\"NONE\"?>\n"
    b.OFX {
      b.SIGNONMSGSRSV1 {
        b.SONRS {
          b.STATUS {
            b.CODE 0
            b.SEVERITY "INFO"
          }
          b.DTSERVER Date.today.strftime('%Y%m%d')
          b.LANGUAGE "ENG"
          b.FI {
            b.ORG @bankname
            b.FID @accountnr
          }
        }
      }       
    
      b.BANKMSGSRSV1 {
        b.STMTTRNRS {
          b.TRNUID 0
          b.STATUS {
            b.CODE 0
            b.SEVERITY "INFO"
          }
          b.STMTRS {
            b.CURDEF "EUR"
            b.BANKACCTFROM {
              b.BANKID 123456789
              b.ACCTID @accountnr
              b.ACCTTYPE "CHECKING"
            }  
            b.BANKTRANLIST {
              b.DTSTART @startdate.strftime('%Y%m%d')
              b.DTEND @enddate.strftime('%Y%m%d')
                
      @parse_result.each do |account_number, bank_statements|
        bank_statements.each do |bank_statement|
          bank_statement.transactions.each do |t|
             b.STMTTRN {
                b.TINTYPE 
                b.DTPOSTED t.date.strftime('%Y%m%d')
                b.TRNAMT t.amount
                b.FITID Digest::SHA1.base64digest(
                  t.type.to_s+
                  t.date.strftime('%Y%m%d')+
                  t.amount.to_s+
                  t.contra_account.to_s+
                  t.description
                )
                b.NAME t.contra_account_owner
                b.BANKACCTTO {
                  b.BANKID ""
                  b.ACCTID t.contra_account_iban
                  b.ACCTTYPE ""
                }
                b.MEMO t.description
              }
          end
        end
      end        
      }
    }
  }
}
}      

aFile = File.new(ARGV[0]+".ofx", "w")
aFile.write(buffer)
aFile.close

