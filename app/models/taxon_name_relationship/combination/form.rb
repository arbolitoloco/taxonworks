class TaxonNameRelationship::Combination::Form < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants
  end


  def self.assignable
    true
  end

end
