if (elementId.indexOf('filter_link_lyr_') != -1)
{
	itemId = elementId.substring('filter_link_lyr_'.length);
	removeParameterItem("lkey", itemId);
}