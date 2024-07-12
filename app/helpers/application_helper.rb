module ApplicationHelper

  # UMD Customization
  def from_subquery(subquery_field, args)
    # UMD Blacklight 8 fix
    # see https://github.com/projectblacklight/blacklight/commit/dcfc74aebd4446aac85b2c2f7d10cd2c6ff8fef3
    # Can no longer assign to args[:document], so just return the value
    args[:document][subquery_field]['docs']
    # End UMD Blacklight 8 fix
  end

  def collection_from_subquery(args)
    from_subquery 'pcdm_collection_info', args
  end

  def parent_from_subquery(args)
    from_subquery 'pcdm_member_of_info', args
  end

  def members_from_subquery(args)
    from_subquery 'pcdm_members_info', args
  end

  def value_list(args)
    args[:document][args[:field]]
  end
  # End UMD Customization
end
