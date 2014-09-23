module PinboardItemsHelper

  def pin_item_to_pinboard_link(object, user)
    if user.pinboard_items.for_object(object).count == 0
      link_to('Add to pinboard', pinboard_items_path(pinboard_item: {pinned_object_id: object.id, pinned_object_type: object.class.base_class.name}), method: :post) # needs becomes
    else
      content_tag(:em, 'this record is pinned!')
    end
  end


end
