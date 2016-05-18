function tag_name = get_tag_name(tag_id, clothings)
    ind = find(clothings{1} == tag_id);
    tag_name = clothings{2}{ind};
end