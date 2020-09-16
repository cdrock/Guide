import "relay/Guide/Support/HTML.ash"
import "relay/Guide/Support/KOLImage.ash"
import "relay/Guide/Support/List.ash"
import "relay/Guide/Support/Page.ash"
import "relay/Guide/Support/Library.ash"
import "relay/Guide/Settings.ash"


record ChecklistSubentry
{
	string header;
	string [int] modifiers;
	string [int] entries;
};


ChecklistSubentry ChecklistSubentryMake(string header, string [int] modifiers, string [int] entries)
{
	boolean all_subentries_are_empty = true;
	foreach key in entries
	{
		if (entries[key] != "")
			all_subentries_are_empty = false;
	}
	ChecklistSubentry result;
	result.header = header;
	result.modifiers = modifiers;
	if (!all_subentries_are_empty)
		result.entries = entries;
	return result;
}

ChecklistSubentry ChecklistSubentryMake(string header, string modifiers, string [int] entries)
{
	if (modifiers == "")
		return ChecklistSubentryMake(header, listMakeBlankString(), entries);
	else
		return ChecklistSubentryMake(header, listMake(modifiers), entries);
}


ChecklistSubentry ChecklistSubentryMake(string header, string [int] entries)
{
	return ChecklistSubentryMake(header, listMakeBlankString(), entries);
}

ChecklistSubentry ChecklistSubentryMake(string header, string [int] modifiers, string e1)
{
	return ChecklistSubentryMake(header, modifiers, listMake(e1));
}

ChecklistSubentry ChecklistSubentryMake(string header, string [int] modifiers, string e1, string e2)
{
	return ChecklistSubentryMake(header, modifiers, listMake(e1, e2));
}


ChecklistSubentry ChecklistSubentryMake(string header, string modifiers, string e1)
{
	if (modifiers == "")
		return ChecklistSubentryMake(header, listMakeBlankString(), listMake(e1));
	else
		return ChecklistSubentryMake(header, listMake(modifiers), listMake(e1));
}

ChecklistSubentry ChecklistSubentryMake(string header)
{
	return ChecklistSubentryMake(header, "", "");
}

void listAppend(ChecklistSubentry [int] list, ChecklistSubentry entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listPrepend(ChecklistSubentry [int] list, ChecklistSubentry entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}

ChecklistSubentry [int] listMake(ChecklistSubentry e1)
{
	ChecklistSubentry [int] result;
	result.listAppend(e1);
	return result;
}


int CHECKLIST_DEFAULT_IMPORTANCE = 0;
record ChecklistEntry
{
	string image_lookup_name;
	string url;
    string [string] container_div_attributes;
	ChecklistSubentry [int] subentries;
	boolean should_indent_after_first_subentry;
    
    boolean should_highlight;
	
	int importance_level; //Entries will be resorted by importance level before output, ascending order. Default importance is 0. Convention is to vary it from [-11, 11] for reasons that are clear and well supported in the narrative.
    boolean only_show_as_extra_important_pop_up; //only valid if -11 importance or lower - only shows up as a pop-up, meant to inform the user they can scroll up to see something else (semi-rares)
    ChecklistSubentry [int] subentries_on_mouse_over; //replaces subentries
    
    string combination_tag; //Entries with identical combination tags will be combined into one, with the "first" taking precedence.
};


ChecklistEntry ChecklistEntryMake(string image_lookup_name, string url, ChecklistSubentry [int] subentries, int importance, boolean should_highlight)
{
	ChecklistEntry result;
	result.image_lookup_name = image_lookup_name;
	result.url = url;
	result.subentries = subentries;
	result.importance_level = importance;
    result.should_highlight = should_highlight;
	return result;
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries, int importance)
{
    return ChecklistEntryMake(image_lookup_name, target_location, subentries, importance, false);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries, int importance, boolean [location] highlight_if_last_adventured)
{
    boolean should_highlight = false;
    
    if (highlight_if_last_adventured contains __last_adventure_location)
        should_highlight = true;
    return ChecklistEntryMake(image_lookup_name, target_location, subentries, importance, should_highlight);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries)
{
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, CHECKLIST_DEFAULT_IMPORTANCE);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry [int] subentries, boolean [location] highlight_if_last_adventured)
{
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, CHECKLIST_DEFAULT_IMPORTANCE, highlight_if_last_adventured);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry subentry, int importance)
{
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, importance);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry subentry, int importance, boolean [location] highlight_if_last_adventured)
{
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, importance, highlight_if_last_adventured);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry subentry)
{
	return ChecklistEntryMake(image_lookup_name, target_location, subentry, CHECKLIST_DEFAULT_IMPORTANCE);
}

ChecklistEntry ChecklistEntryMake(string image_lookup_name, string target_location, ChecklistSubentry subentry, boolean [location] highlight_if_last_adventured)
{
	ChecklistSubentry [int] subentries;
	subentries[subentries.count()] = subentry;
	return ChecklistEntryMake(image_lookup_name, target_location, subentries, CHECKLIST_DEFAULT_IMPORTANCE, highlight_if_last_adventured);
}

//Secondary level of making checklist entries; setting properties and returning them.
ChecklistEntry ChecklistEntryTagEntry(ChecklistEntry e, string tag)
{
    e.combination_tag = tag;
    return e;
}


void listAppend(ChecklistEntry [int] list, ChecklistEntry entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(ChecklistEntry [int] list, ChecklistEntry [int] entries)
{
	foreach key in entries
		list.listAppend(entries[key]);
}

void listClear(ChecklistEntry [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}


record Checklist
{
	string title;
	ChecklistEntry [int] entries;
    
    boolean disable_generating_id; //disable generating checklist anchor and title-based div identifier
};


Checklist ChecklistMake(string title, ChecklistEntry [int] entries)
{
	Checklist cl;
	cl.title = title;
	cl.entries = entries;
	return cl;
}

Checklist ChecklistMake()
{
	Checklist cl;
	return cl;
}

void listAppend(Checklist [int] list, Checklist entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listRemoveKeys(Checklist [int] list, int [int] keys_to_remove)
{
	foreach i in keys_to_remove
	{
		int key = keys_to_remove[i];
		if (!(list contains key))
			continue;
		remove list[key];
	}
}


string ChecklistGenerateModifierSpan(string [int] modifiers)
{
    if (modifiers.count() == 0)
        return "";
	return HTMLGenerateSpanOfClass(modifiers.listJoinComponents(", "), "r_cl_modifier");
}

string ChecklistGenerateModifierSpan(string modifier)
{
	return HTMLGenerateSpanOfClass(modifier, "r_cl_modifier");
}


void ChecklistInit()
{
	PageAddCSSClass("a", "r_cl_internal_anchor", "");
    PageAddCSSClass("", "r_cl_modifier_inline", "font-size:0.85em; color:" + __setting_modifier_colour + ";");
    PageAddCSSClass("", "r_cl_modifier", "font-size:0.85em; color:" + __setting_modifier_colour + "; display:block;");
	
	PageAddCSSClass("", "r_cl_header", "text-align:center; font-size:1.15em; font-weight:bold;");
	PageAddCSSClass("", "r_cl_subheader", "font-size:1.07em; font-weight:bold;");
	PageAddCSSClass("div", "r_cl_inter_spacing_divider", "width:100%; height:12px;");
	PageAddCSSClass("div", "r_cl_l_container", "padding-top:5px;padding-bottom:5px;");
    
    string gradient = "background: #ffffff;background: -moz-linear-gradient(left, #ffffff 50%, #F0F0F0 75%, #F0F0F0 100%);background: -webkit-gradient(linear, left top, right top, color-stop(50%,#ffffff), color-stop(75%,#F0F0F0), color-stop(100%,#F0F0F0));background: -webkit-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: -o-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: -ms-linear-gradient(left, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);background: linear-gradient(to right, #ffffff 50%,#F0F0F0 75%,#F0F0F0 100%);filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffffff', endColorstr='#F0F0F0',GradientType=1 );"; //help
	PageAddCSSClass("div", "r_cl_l_container_highlighted", gradient + "padding-top:5px;padding-bottom:5px;");
    
	PageAddCSSClass("div", "r_cl_l_left", "float:left;width:" + __setting_image_width_large + "px;margin-left:20px;overflow:hidden;");
	PageAddCSSClass("div", "r_cl_l_right_container", "width:100%;margin-left:" + (-__setting_image_width_large - 20) + "px;float:right;text-align:left;vertical-align:top;");
	PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + (__setting_image_width_large + 20 + 2) + "px;display:inline-block;margin-right:20px;");
    
    PageAddCSSClass("hr", "r_cl_hr", "padding:0px;margin-top:0px;margin-bottom:0px;width:auto; margin-left:" + __setting_indention_width + ";margin-right:" + __setting_indention_width +";");
    PageAddCSSClass("hr", "r_cl_hr_extended", "padding:0px;margin-top:0px;margin-bottom:0px;width:auto; margin-left:" + __setting_indention_width + ";margin-right:0px;");
	PageAddCSSClass("div", "r_cl_holding_container", "display:inline-block;");
    //PageAddCSSClass("div", "r_cl_holding_container.r_cl_collapsed","display:none;");
    PageAddCSSClass("div", "r_cl_collapsed","display:none;");
    PageAddCSSClass("div", "r_cl_minimize_button", "width:0px;height:0px;float:right;direction:rtl;position:relative;z-index:2;user-select:none;color:#7F7F7F;margin-right:" + __setting_indention_width + ";");
	
    
    PageAddCSSClass("", "r_cl_image_container_large", "display:block;");
    PageAddCSSClass("", "r_cl_image_container_medium", "display:none;");
    PageAddCSSClass("", "r_cl_image_container_small", "display:none;");
    
	if (true)
	{
		string div_style = "";
		div_style = "margin:0px; border:1px; border-style: solid; border-color:" + __setting_line_colour + ";";
        div_style += "border-left:0px; border-right:0px;";
        div_style += "background-color:#FFFFFF; width:100%; padding-top:5px;";
		PageAddCSSClass("div", "r_cl_checklist_container", div_style);
	}
    
    //media queries:
    if (!__use_table_based_layouts)
    {
        PageAddCSSClass("div", "r_cl_l_left", "width:" + __setting_image_width_medium + "px;margin-left:5px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("div", "r_cl_l_right_container", "margin-left:" + (-__setting_image_width_medium - 5) + "px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + (__setting_image_width_medium + 5 + 2) + "px;margin-right:10px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("div", "r_cl_l_container", "padding-top:4px;padding-bottom:4px;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:" + (__setting_indention_width_in_em / 2.0) + "em;margin-right:" + (__setting_indention_width_in_em / 2.0) +"em;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:" + (__setting_indention_width_in_em / 2.0) + "em;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("div", "r_cl_minimize_button", "margin-right:" + (__setting_indention_width_in_em / 2.0) + "em;", 0, __setting_media_query_medium_size);
        
        
        PageAddCSSClass("div", "r_cl_l_left", "width:" + (__setting_image_width_small) + "px;margin-left:5px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("div", "r_cl_l_right_container", "margin-left:" + (-(__setting_image_width_small) - 10) + "px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + ((__setting_image_width_small) + 10) + "px;margin-right:3px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:0px;margin-right:0px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:0px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("div", "r_cl_l_container", "padding-top:3px;padding-bottom:3px;", 0, __setting_media_query_small_size);
        PageAddCSSClass("div", "r_cl_minimize_button", "margin-right:0px;", 0, __setting_media_query_small_size);
        
        
        PageAddCSSClass("div", "r_cl_l_left", "width:" + (0) + "px;margin-left:3px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("div", "r_cl_l_right_container", "margin-left:" + (-(0) - 3) + "px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:" + ((0) + 3 + 2) + "px;margin-right:3px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("hr", "r_cl_hr", "margin-left:0px;margin-right:0px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("hr", "r_cl_hr_extended", "margin-left:0px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("div", "r_cl_l_container", "padding-top:3px;padding-bottom:3px;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("div", "r_cl_minimize_button", "margin-right:0px;", 0, __setting_media_query_tiny_size);
        
        
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_medium_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:block;", 0, __setting_media_query_medium_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:none;", 0, __setting_media_query_medium_size);
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:none;", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:block;", 0, __setting_media_query_small_size);
        
        PageAddCSSClass("", "r_cl_image_container_large", "display:none", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("", "r_cl_image_container_medium", "display:none;", 0, __setting_media_query_tiny_size);
        PageAddCSSClass("", "r_cl_image_container_small", "display:none;", 0, __setting_media_query_tiny_size);
        
        PageAddCSSClass("", "r_small_float_indention", "display:none");
        
        PageAddCSSClass("", "r_indention_not_small", "margin-left:" + __setting_indention_width + ";");
        if (__setting_small_size_uses_full_width)
        {
            PageAddCSSClass("div", "r_cl_l_right_content", "margin-left:10px;margin-right:3px;min-width:80%;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_cl_image_container_small", "display:block;float:left;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_small_float_indention", "display:inline;width:0.5em;float:left;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_indention_not_small", "margin-left:0.75em;", 0, __setting_media_query_small_size);
            PageAddCSSClass("", "r_indention_not_small", "margin-left:0.75em;", 0, __setting_media_query_tiny_size);
        }
        
        
        PageAddCSSClass("", "r_indention", "margin-left:0.75em;", 0, __setting_media_query_small_size);
        PageAddCSSClass("", "r_indention", "margin-left:0.75em;", 0, __setting_media_query_tiny_size);
    }
}

//Creates if not found:
Checklist lookupChecklist(Checklist [int] checklists, string title)
{
	foreach key in checklists
	{
		Checklist cl = checklists[key];
		if (cl.title == title)
			return cl;
	}
	//Not found, create one.
	Checklist cl = ChecklistMake();
	cl.title = title;
	checklists.listAppend(cl);
	return cl;
}

void ChecklistFormatSubentry(ChecklistSubentry subentry) {
    foreach i in subentry.entries {
        string [int] line_split = split_string_alternate(subentry.entries[i], "\\|");
        foreach l in line_split {
            if (stringHasPrefix(line_split[l], "*")) {
                // Indent
                line_split[l] = HTMLGenerateIndentedText(substring(line_split[l], 1));
            }
        }

        // Recombine
        buffer building_line;
        boolean first = true;
        boolean last_was_indention = false;
        foreach key in line_split {
            string line = line_split[key];
            if (!contains_text(line, "class=\"r_indention\"") && !first && !last_was_indention) {
                building_line.append("<br>");
            }
            last_was_indention = contains_text(line, "class=\"r_indention\"");
            building_line.append(line);
            first = false;
        }
        subentry.entries[i] = to_string(building_line);
    }
}

buffer ChecklistGenerateEntryHTML(ChecklistEntry entry, ChecklistSubentry [int] subentries, boolean outputting_anchor, buffer anchor_prefix_html, buffer anchor_suffix_html, boolean setting_use_holding_containers_per_subentry) {
    Vec2i max_image_dimensions_large = Vec2iMake(__setting_image_width_large, 75);
    Vec2i max_image_dimensions_medium = Vec2iMake(__setting_image_width_medium, 50);
    Vec2i max_image_dimensions_small = Vec2iMake(__setting_image_width_small, 50);
    if (__setting_small_size_uses_full_width) {
        max_image_dimensions_small = Vec2iMake(__setting_image_width_small,__setting_image_width_small);
    }

    buffer result;
    buffer image_container;
    string entry_id_raw = entry.subentries[0].header + entry.importance_level.to_string().replace_string("-","minus");
    string entry_id = create_matcher("[^0-9a-zA-Z]", entry_id_raw).replace_all(""); //remove characters that break the .js
    
    if (outputting_anchor && !__setting_entire_area_clickable) {
        image_container.append(anchor_prefix_html);
    }
    
    image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_large, "r_cl_image_container_large"));
    image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_medium, "r_cl_image_container_medium"));

    if (!__setting_small_size_uses_full_width) {
        image_container.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_small, "r_cl_image_container_small"));
    }
    
    if (outputting_anchor && !__setting_entire_area_clickable) {
        image_container.append(anchor_suffix_html);
    }
    
    result.append(HTMLGenerateDivOfClass(image_container, "r_cl_l_left"));
    result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_cl_l_right_container")));
    
    if (true) { //minimize button
        boolean entry_has_content_to_minimize = false;
        int indented_entries;
        foreach j, subentry in subentries {
            if (subentry.header == "")
                continue;
            
            if (entry.should_indent_after_first_subentry)
                indented_entries++;
            if (subentry.entries.count() > 0 || indented_entries >= 2) {
                entry_has_content_to_minimize = true;
                break;
            }
        }

        if (entry_has_content_to_minimize) {
            result.append(HTMLGenerateTagWrap("div", "&#9660;", string [string] {"class":"r_cl_minimize_button","alt":"Minimize","title":"Minimize","id":"toggle_" + entry_id,"onclick":"alterSubentryMinimization(event)","style":"cursor:zoom-out;"}));
        }
    }
    
    if (outputting_anchor && !__setting_entire_area_clickable) {
        result.append(anchor_prefix_html);
    }

    result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_cl_l_right_content")));
    
    if (__setting_small_size_uses_full_width) {
        result.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_small, "r_cl_image_container_small"));
        result.append(HTMLGenerateTagWrap("div", "", mapMake("class", "r_small_float_indention", "style", "height: " + __kol_image_generate_image_html_return_final_size.y + "px;")));
    }
    
    boolean first = true;
    boolean indented_after_first_subentry = false;
    foreach j in subentries {
        ChecklistSubentry subentry = subentries[j];
        if (subentry.header == "")
            continue;
        string subheader = subentry.header;
        
        if (first)
        {
            first = false;
        }
        else if (entry.should_indent_after_first_subentry && !indented_after_first_subentry)
        {
            result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_indention " + entry_id)));
            indented_after_first_subentry = true;
        }
        
        result.append(HTMLGenerateSpanOfClass(subheader, "r_cl_subheader"));
        string content_indention = __setting_small_size_uses_full_width ? "r_indention_not_small" : "r_indention";
        result.append( //this mini-abomination is necessary; an empty r_indention is the only thing preventing chaining headers from being in a single file, when minimized
            (subentry.modifiers.count() > 0 ?
                    subentry.modifiers.listJoinComponents(", ").ChecklistGenerateModifierSpan() : ""
            ).HTMLGenerateDivOfClass(content_indention)
        );

        result.append(HTMLGenerateTagPrefix("div", mapMake("class", content_indention + (indented_after_first_subentry ? "" : " " + entry_id) )));
        if (subentry.entries.count() > 0)
        {
            int intra_k = 0;
            if (setting_use_holding_containers_per_subentry)
                result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_cl_holding_container"))); //HRs
            while (intra_k < subentry.entries.count())
            { 
                if (intra_k > 0)
                    result.append("<hr>");
                string line = subentry.entries[listKeyForIndex(subentry.entries, intra_k)];
                
                //if (line.contains_text("<hr"))
                line = HTMLGenerateDivOfClass(line, "r_cl_holding_container"); //For nested HRs, sizes them down a bit
                
                result.append(line);
                
                intra_k += 1;
            }
            if (setting_use_holding_containers_per_subentry)
                result.append("</div>");
        }
        result.append("</div>");
    }
    if (indented_after_first_subentry)
        result.append("</div>");
    result.append("</div>");
    if (outputting_anchor && !__setting_entire_area_clickable)
        result.append(anchor_suffix_html);
    result.append("</div>");
    result.append(HTMLGenerateDivOfClass("", "r_end_floating_elements")); //stop floating
    return result;
}

/**
Generates HTML for a checklist and appends it to the DOM
@param cl The checklist being appended to the DOM
@param output_borders Whether or not to add borders
*/
buffer ChecklistGenerate(Checklist cl, boolean output_borders) {
	ChecklistEntry [int] entries = cl.entries;
	
	//Combine entries with identical combination tags:
	ChecklistEntry [string] combination_tag_entries;
	foreach key, entry in entries {
		if (entry.combination_tag == "") continue;
        if (entry.only_show_as_extra_important_pop_up) continue; //do not support this feature with this
        if (entry.subentries_on_mouse_over.count() > 0) continue;
        if (entry.container_div_attributes.count() > 0) continue;
        
        if (!(combination_tag_entries contains entry.combination_tag)) {
        	entry.importance_level -= 1; //combined entries gain a hack; a level above everything else
        	combination_tag_entries[entry.combination_tag] = entry;
            continue;
        }

        ChecklistEntry master_entry = combination_tag_entries[entry.combination_tag];
        
        if (entry.should_highlight) {
        	master_entry.should_highlight = true;
        }

        if (master_entry.url == "" && entry.url != "") {
        	master_entry.url = entry.url;
        }

        master_entry.importance_level = min(master_entry.importance_level, entry.importance_level - 1);
        
        foreach key, subentry in entry.subentries { 
        	master_entry.subentries.listAppend(subentry);
        }

        remove entries[key];
	}
	
	//Sort by importance:
	sort entries by value.importance_level;
	
    //Format subentries:
    foreach index in entries {
        ChecklistEntry entry = entries[index];
        foreach subentryIndex in entry.subentries {
            ChecklistFormatSubentry(entry.subentries[subentryIndex]);
        }
        foreach subentryIndex in entry.subentries_on_mouse_over {
            ChecklistFormatSubentry(entry.subentries_on_mouse_over[subentryIndex]);
        }
    }

	boolean skip_first_entry = false;
	string special_subheader = "";
	if (entries.count() > 0) {
		if (entries[0].image_lookup_name == "special subheader") {
			if (entries[0].subentries.count() > 0) {
				special_subheader = entries[0].subentries[0].header;
				skip_first_entry = true;
			}
		}
	}
	
	buffer result;
    if (output_borders)
        result.append(HTMLGenerateDivOfClass("", "r_cl_inter_spacing_divider")); //spacing
	
    if (!cl.disable_generating_id)
        result.append(HTMLGenerateTagWrap("a", "", mapMake("id", HTMLConvertStringToAnchorID(cl.title), "class", "r_cl_internal_anchor")));
	
    string [string] main_container_map;
    main_container_map["class"] = "r_cl_checklist_container";
    if (!cl.disable_generating_id)
        main_container_map["id"] = HTMLConvertStringToAnchorID(cl.title + " checklist container");
    if (!output_borders)
        main_container_map["style"] = "border:0px;";
    result.append(HTMLGenerateTagPrefix("div", main_container_map));
	
	
	result.append(HTMLGenerateDivOfClass(cl.title, "r_cl_header"));
	
	if (special_subheader != "")
		result.append(ChecklistGenerateModifierSpan(special_subheader));
	
	int starting_intra_i = 0;
	if (skip_first_entry)
		starting_intra_i = 1;
	int intra_i = 0;
	int entries_output = 0;
    boolean last_was_highlighted = false;
    int current_mouse_over_id = 1;
	foreach i in entries
	{
		if (intra_i < starting_intra_i)
		{
			intra_i += 1;
			continue;
		}
		ChecklistEntry entry = entries[i];
		if (intra_i > starting_intra_i)
		{
            boolean next_is_highlighted = false;
            if (entry.should_highlight)
                next_is_highlighted = true;
            string class_name = "r_cl_hr";
            if (last_was_highlighted || next_is_highlighted)
                class_name = "r_cl_hr_extended";
			result.append(HTMLGenerateTagPrefix("hr", mapMake("class", class_name)));
		}
        if (__use_table_based_layouts)
            __setting_entire_area_clickable = true;
		boolean outputting_anchor = false;
        buffer anchor_prefix_html;
        buffer anchor_suffix_html;
		if (entry.url != "")
		{
            anchor_prefix_html = HTMLGenerateTagPrefix("a", mapMake("target", "mainpane", "href", entry.url, "class", "r_a_undecorated"));
			anchor_suffix_html.append("</a>");
			outputting_anchor = true;
		}
        if (outputting_anchor && __setting_entire_area_clickable)
			result.append(anchor_prefix_html);
		
		boolean setting_use_holding_containers_per_subentry = true;
			
		Vec2i max_image_dimensions_large = Vec2iMake(__setting_image_width_large, 75);
		Vec2i max_image_dimensions_medium = Vec2iMake(__setting_image_width_medium, 50);
		Vec2i max_image_dimensions_small = Vec2iMake(__setting_image_width_small, 50);
        if (__setting_small_size_uses_full_width)
            max_image_dimensions_small = Vec2iMake(__setting_image_width_small,__setting_image_width_small);
        
        string container_class = "r_cl_l_container";
        if (entry.should_highlight)
            container_class = "r_cl_l_container_highlighted";
        last_was_highlighted = entry.should_highlight;
        
        buffer generated_subentry_html = ChecklistGenerateEntryHTML(entry, entry.subentries, outputting_anchor, anchor_prefix_html, anchor_suffix_html, setting_use_holding_containers_per_subentry);
        if (entry.subentries_on_mouse_over.count() > 0)
        {
            buffer generated_mouseover_subentry_html = ChecklistGenerateEntryHTML(entry, entry.subentries_on_mouse_over, outputting_anchor, anchor_prefix_html, anchor_suffix_html, setting_use_holding_containers_per_subentry);
            
            //Can't properly escape, so generate two no-show divs and replace them as needed:
            //We could just have a div that shows up when we mouse over...
            //This is currently very buggy.
            entry.container_div_attributes["onmouseenter"] = "event.currentTarget.innerHTML = document.getElementById('r_temp_o" + current_mouse_over_id + "').innerHTML";
            entry.container_div_attributes["onmouseleave"] = "event.currentTarget.innerHTML = document.getElementById('r_temp_l" + current_mouse_over_id + "').innerHTML";
            
            result.append(HTMLGenerateTagPrefix("div", mapMake("id", "r_temp_o" + current_mouse_over_id, "style", "display:none")));
            result.append(generated_mouseover_subentry_html);
            result.append(HTMLGenerateTagSuffix("div"));
            result.append(HTMLGenerateTagPrefix("div", mapMake("id", "r_temp_l" + current_mouse_over_id, "style", "display:none")));
            result.append(generated_subentry_html);
            result.append(HTMLGenerateTagSuffix("div"));
            
            current_mouse_over_id += 1;
        }
        
        entry.container_div_attributes["class"] += (entry.container_div_attributes contains "class" ? " " : "") + container_class;
        result.append(HTMLGenerateTagPrefix("div", entry.container_div_attributes));
        
		if (__use_table_based_layouts)
		{
			//table-based layout:
			result.append("<table cellpadding=0 cellspacing=0><tr>");
			
			result.append(HTMLGenerateTagWrap("td", "", mapMake("style", "width:" + __setting_indention_width + ";")));
			result.append("<td>");
			result.append(HTMLGenerateTagPrefix("td", mapMake("style", "min-width:" + __setting_image_width_large + "px; max-width:" + __setting_image_width_large + "px; width:" + __setting_image_width_large + "px;vertical-align:top; text-align: center;")));
			
			result.append(KOLImageGenerateImageHTML(entry.image_lookup_name, true, max_image_dimensions_large));
			
			result.append("</td>");
			result.append(HTMLGenerateTagPrefix("td", mapMake("style", "text-align:left; vertical-align:top")));
			
				
			boolean first = true;
            boolean indented_after_first_subentry = false;
			foreach j in entry.subentries
			{
				ChecklistSubentry subentry = entry.subentries[j];
				if (subentry.header == "")
					continue;
				string subheader = subentry.header;
				
				if (first)
				{
					first = false;
				}
				else if (entry.should_indent_after_first_subentry && !indented_after_first_subentry)
				{
					result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_indention")));
					indented_after_first_subentry = true;
				}
				
				result.append("<table cellpadding=0 cellspacing=0><tr><td colspan=2>");
			
				result.append(HTMLGenerateSpanOfClass(subheader, "r_cl_subheader"));
				
				result.append("</td></tr>");
				
				
				result.append("<tr>");
				result.append(HTMLGenerateTagWrap("td", "", mapMake("style", "width:" + __setting_indention_width + ";")));
				result.append("<td>");
				if (subentry.modifiers.count() > 0)
					result.append(ChecklistGenerateModifierSpan(listJoinComponents(subentry.modifiers, ", ") + "<br>"));
				if (subentry.entries.count() > 0)
				{
					int intra_k = 0;
					while (intra_k < subentry.entries.count())
					{ 
						if (intra_k > 0)
							result.append("<hr>");
						string line = subentry.entries[listKeyForIndex(subentry.entries, intra_k)];
						line = HTMLGenerateDivOfClass(line, "r_cl_holding_container"); //For nested HRs
						
						
						result.append(line);
						
						intra_k += 1;
					}
				}
				result.append("</td></tr>");
				
				result.append("</table>");
			}
			if (indent_this_entry)
				result.append("</div>");
			result.append("</td>");
			result.append("</tr></table>");
		}
		else
		{
            result.append(generated_subentry_html);
		}
        result.append("</div>");

		
		if (outputting_anchor && __setting_entire_area_clickable)
            result.append(anchor_suffix_html);
		
		intra_i += 1;
		entries_output += 1;
	}
	result.append("</div>");
	
    if (output_borders)
        result.append(HTMLGenerateDivOfClass("", "r_cl_inter_spacing_divider"));
	
	return result;
}

/**
Attaches checklist to DOM.
@param checklist The checklist being appended.
*/
buffer ChecklistGenerate(Checklist checklist) {
    return ChecklistGenerate(checklist, true);
}


Record ChecklistCollection
{
    Checklist [string] checklists;
};

//NOTE: WILL DESTRUCTIVELY EDIT CHECKLISTS GIVEN TO IT
//mostly because there's no easy way to copy an object in ASH
//without manually writing a copy function and insuring it is synched
Checklist [int] ChecklistCollectionMergeWithLinearList(ChecklistCollection collection, Checklist [int] other_checklists)
{
    Checklist [int] result;
    
    boolean [string] seen_titles;
    foreach key, checklist in other_checklists
    {
        seen_titles[checklist.title] = true;
        result.listAppend(checklist);
    }
    foreach key, checklist in collection.checklists
    {
        if (seen_titles contains checklist.title)
        {
            foreach key, checklist2 in result
            {
                if (checklist2.title == checklist.title)
                {
                    checklist2.entries.listAppendList(checklist.entries);
                    break;
                }
            }
        }
        else
        {
            result.listAppend(checklist);
        }
    }
    
    return result;
}

Checklist lookup(ChecklistCollection collection, string name)
{
    if (collection.checklists contains name)
        return collection.checklists[name];
    
    Checklist c = ChecklistMake();
    c.title = name;
    collection.checklists[c.title] = c;
    return c;
}
