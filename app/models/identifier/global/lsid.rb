class Identifier::Global::Lsid < Identifier::Global
  # urn:lsid:Orthoptera.speciesfile.org:TaxonName:1
=begin
  • "URN"
  • "LSID"
  • authority identification
  • namespace identification
  • object identification
  • optionally: revision identification. If revision field is omitted then the trailing colon is also omitted.
=end
  validate :using_lsid_class

  def using_lsid_class
    retval = true
    unless identifier.nil?
      lsid = identifier.split(':')
      # this is a test of http://rubular.com/regexes/13295
      /SID=([\s\S]*?)LSID=([\s\S]*?)Auth=([\s\S]*)/ =~ identifier

      unless lsid.length.between?(5, 6)
        unless lsid[0].upcase == 'URN' and lsid[1].upcase == 'LSID'
          errors.add(:identifier, "'#{identifier}' is not a valid LSID.")
          retval = false
        end
      end
    end
    return retval
  end
end
