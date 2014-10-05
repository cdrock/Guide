import "relay/Guide/QuestState.ash"
import "relay/Guide/Support/Checklist.ash"

boolean [item] __pulls_reasonable_to_buy_in_run;

int pullable_amount(item it, int maximum_total_wanted)
{
	boolean buyable_in_run = false;
	if (__pulls_reasonable_to_buy_in_run contains it)
		buyable_in_run = true;
	if (maximum_total_wanted == 0)
		maximum_total_wanted = __misc_state_int["pulls available"] + it.available_amount();
	if (__misc_state["Example mode"]) //simulate pulls
	{
		if (buyable_in_run)
			return min(__misc_state_int["pulls available"], maximum_total_wanted);
		else
			return min(__misc_state_int["pulls available"], min(storage_amount(it) + it.available_amount(), maximum_total_wanted));
	}
	
	int amount = storage_amount(it);
	if (buyable_in_run)
		amount = 20;
	int total_amount = amount + it.available_amount();
	
	if (total_amount > maximum_total_wanted)
	{
		amount = maximum_total_wanted - it.available_amount();
	}
	
	if (amount < 0) amount = 0;
	return min(__misc_state_int["pulls available"], amount);
}

int pullable_amount(item it)
{
	return pullable_amount(it, 0);
}


//generic pull item
record GPItem
{
	//Either item OR alternate_name
	item it;
	string alternate_name;
	string alternate_image_name;
	
	string reason;
	int max_wanted;
};

GPItem GPItemMake(item it, string reason, int max_wanted)
{
	GPItem result;
	result.it = it;
	result.reason = reason;
	result.max_wanted = max_wanted;
	return result;
}

GPItem GPItemMake(item it, string reason)
{
	return GPItemMake(it, reason, 1);
}

GPItem GPItemMake(string alternate_name, string alternate_image_name, string reason)
{
	GPItem result;
	result.alternate_name = alternate_name;
	result.alternate_image_name = alternate_image_name;
	result.reason = reason;
	result.max_wanted = 1;
	return result;
}

void listAppend(GPItem [int] list, GPItem entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void generatePullList(Checklist [int] checklists)
{
    //Needs improvement.
	ChecklistEntry [int] pulls_entries;
	
	int pulls_available = __misc_state_int["pulls available"];
	if (pulls_available <= 0)
		return;
	if (pulls_available > 0)
		pulls_entries.listAppend(ChecklistEntryMake("special subheader", "", ChecklistSubentryMake(pluralize(pulls_available, "pull", "pulls") + " remaining")));
	
	item [int] pullable_list_item;
	int [int] pullable_list_max_wanted;
	string [int] pullable_list_reason;
	
	GPItem [int] pullable_item_list;
	
	//IOTMs:
	if ($items[empty rain-doh can,can of rain-doh,spooky putty monster].available_amount() == 0)
		pullable_item_list.listAppend(GPItemMake($item[spooky putty sheet], "5 copies/day", 1));
	pullable_item_list.listAppend(GPItemMake($item[over-the-shoulder folder holder], "So many things!", 1));
	pullable_item_list.listAppend(GPItemMake($item[pantsgiving], "5x banish/day|+2 stats/fight|+15% items|2 extra fullness (realistically)", 1));
    if (!__misc_state["familiars temporarily blocked"]) //relevant in heavy rains, on the +item/+meat underwater familiars
        pullable_item_list.listAppend(GPItemMake($item[snow suit], "+20 familiar weight for a while" + (__misc_state["free runs usable"] ? ", +4 free runs" : "") + "|+10% item|spleen items", 1));
    if (!__misc_state["familiars temporarily blocked"])
    {
        if ($item[Buddy Bjorn].storage_amount() > 0)
            pullable_item_list.listAppend(GPItemMake(lookupItem("Buddy Bjorn"), "+10ML/+lots MP hat|or +item/+init/+meat/etc", 1));
        else if ($item[buddy bjorn].available_amount() == 0)
            pullable_item_list.listAppend(GPItemMake($item[crown of thrones], "+10ML/+lots MP hat|or +item/+init/+meat/etc", 1));
    }
	pullable_item_list.listAppend(GPItemMake($item[boris's helm], "+15ML/+5 familiar weight/+init/+mp regeneration/+weapon damage", 1));
	if ($item[empty rain-doh can].available_amount() == 0 && $item[can of rain-doh].available_amount() == 0)
		pullable_item_list.listAppend(GPItemMake($item[can of rain-doh], "5 copies/day|everything really", 1));
    if (__misc_state["need to level"])
    {
        pullable_item_list.listAppend(GPItemMake($item[plastic vampire fangs], "Large stat gain, once/day.", 1));
        pullable_item_list.listAppend(GPItemMake($item[operation patriot shield], "?", 1));
    }
    pullable_item_list.listAppend(GPItemMake($item[v for vivala mask], "?", 1));
	
	if (my_primestat() == $stat[mysticality] && my_path_id() != PATH_HEAVY_RAINS) //should we only suggest this for mysticality classes?
		pullable_item_list.listAppend(GPItemMake($item[Jarlsberg's Pan], "?", 1)); //"
	pullable_item_list.listAppend(GPItemMake($item[loathing legion knife], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[greatest american pants], "navel runaways|others", 1));
	pullable_item_list.listAppend(GPItemMake($item[juju mojo mask], "towerkilling?", 1));
    if (__misc_state["free runs usable"])
        pullable_item_list.listAppend(GPItemMake($item[navel ring of navel gazing], "free runaways|easy fights", 1));
	//pullable_item_list.listAppend(GPItemMake($item[haiku katana], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[bottle-rocket crossbow], "?", 1));
	pullable_item_list.listAppend(GPItemMake($item[jekyllin hide belt], "+variable% item", 3));
    
    if (__misc_state["Need to level"])
    {
        pullable_item_list.listAppend(GPItemMake($item[hockey stick of furious angry rage], "+30ML accessory.", 1));
    }
    pullable_item_list.listAppend(GPItemMake($item[ice sickle], "+15ML 1h weapon|+item/+meat/+init foldables", 1));
    if ($item[buddy bjorn].available_amount() == 0)
        pullable_item_list.listAppend(GPItemMake($item[camp scout backpack], "+15% items on back", 1));
    if (__misc_state["Torso aware"])
    {
        pullable_item_list.listAppend(GPItemMake($item[flaming pink shirt], "+15% items on shirt. (marginal)" + (__misc_state["familiars temporarily blocked"] ? "" : "|Or extra experience on familiar. (very marginal)"), 1));
        if (__misc_state["Need to level"] && lookupItem("Sneaky Pete's leather jacket (collar popped)").available_amount() == 0 && lookupItem("Sneaky Pete's leather jacket").available_amount() == 0)
        {
            
            if (lookupItem("Sneaky Pete's leather jacket (collar popped)").storage_amount() + lookupItem("Sneaky Pete's leather jacket").storage_amount() > 0)
            {
                if (my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
                    pullable_item_list.listAppend(GPItemMake(lookupItem("Sneaky Pete's leather jacket"), "+30ML/+meat/+adv/+init/+moxie shirt", 1));
            }
            else
                pullable_item_list.listAppend(GPItemMake($item[cane-mail shirt], "+20ML shirt", 1));
        }
    }
    
	
	boolean have_super_fairy = false;
	if ((familiar_is_usable($familiar[fancypants scarecrow]) && $item[spangly mariachi pants].available_amount() > 0) || (familiar_is_usable($familiar[mad hatrack]) && $item[spangly sombrero].available_amount() > 0))
		have_super_fairy = true;
	if (!have_super_fairy)
	{
		if (familiar_is_usable($familiar[fancypants scarecrow]))
			pullable_item_list.listAppend(GPItemMake($item[spangly mariachi pants], "2x fairy", 1));
		else if (familiar_is_usable($familiar[mad hatrack]))
			pullable_item_list.listAppend(GPItemMake($item[spangly sombrero], "2x fairy", 1));
	}
	//pullable_item_list.listAppend(GPItemMake($item[jewel-eyed wizard hat], "a wizard is you!", 1));
	//pullable_item_list.listAppend(GPItemMake($item[origami riding crop], "+5 stats/fight, but only if the monster dies quickly", 1)); //not useful?
	//pullable_item_list.listAppend(GPItemMake($item[plastic pumpkin bucket], "don't know", 1)); //not useful?
	//pullable_item_list.listAppend(GPItemMake($item[packet of mayfly bait], "why let it go to waste?", 1));
	
	if ($items[greatest american pants, navel ring of navel gazing].available_amount() + pullable_amount($item[greatest american pants]) + pullable_amount($item[navel ring of navel gazing]) == 0)
		pullable_item_list.listAppend(GPItemMake($item[peppermint parasol], "free runaways", 1));
		
	
	if (__misc_state["can eat just about anything"] && availableFullness() > 0)
	{
        string [int] food_selections;
        
        if (__misc_state_int["fat loot tokens needed"] > 0)
            food_selections.listAppend("key lime pies");
        if (availableFullness() >= 5)
        {
            if ($item[moon pie].is_unrestricted() && !($skill[saucemaven].have_skill() && my_primestat() == $stat[mysticality]))
                food_selections.listAppend("moon pies");
            else if ($skill[saucemaven].have_skill())
                food_selections.listAppend("hi meins");
        }
        
        string description;
        if (food_selections.count() > 0)
            description = food_selections.listJoinComponents(", ") + ", etc.";
		pullable_item_list.listAppend(GPItemMake("Food", "hell ramen", description));
	}
	if (__misc_state["can drink just about anything"] && availableDrunkenness() >= 0 && inebriety_limit() >= 5)
	{
        string [int] drink_selections;
        if ($item[wrecked generator].is_unrestricted())
            drink_selections.listAppend("wrecked generators");
        
        string description;
        if (drink_selections.count() > 0)
            description = drink_selections.listJoinComponents(", ") + ", etc.";
        
		pullable_item_list.listAppend(GPItemMake("Drink", "gibson", description));
	}
    
    if (__misc_state["In run"] && !__quest_state["Level 13"].state_boolean["past gates"] && ($items[large box, blessed large box].available_amount() == 0 && $items[bubbly potion,cloudy potion,dark potion,effervescent potion,fizzy potion,milky potion,murky potion,smoky potion,swirly potion].items_missing().count() > 0))
        pullable_item_list.listAppend(GPItemMake($item[large box], "Combine with clover for blessed large box", 1));
    
    //pullable_item_list.listAppend(GPItemMake($item[slimy alveolus], "40 turns of +50ML (" + floor(40 * 50 * __misc_state_float["ML to mainstat multiplier"]) +" mainstat total, cave bar levelling)|1 spleen", 3)); //marginal now. low-skill oil peak/cyrpt?
	
	
    if (!get_property_boolean("_blankOutUsed") && __misc_state["free runs usable"])
        pullable_item_list.listAppend(GPItemMake($item[bottle of blank-out], "run away from your problems|expensive", 1));
	
	
    if (!__quest_state["Level 11 Hidden City"].finished && !__quest_state["Level 11"].finished && (get_property_int("hiddenApartmentProgress") < 1 || get_property_int("hiddenBowlingAlleyProgress") < 1 || get_property_int("hiddenHospitalProgress") < 1 || get_property_int("hiddenOfficeProgress") < 1) && __misc_state["can equip just about any weapon"])
    {
        boolean have_machete = false;
        foreach it in __dense_liana_machete_items
        {
            if (it.available_amount() > 0 && it.is_unrestricted())
                have_machete = true;
        }
        if (!have_machete)
        {
            if (my_basestat($stat[muscle]) < 62 && $item[machetito].is_unrestricted())
            {
                //machetito
                pullable_item_list.listAppend(GPItemMake($item[machetito], "Machete for dense liana", 1));
            }
            else if (my_basestat($stat[muscle]) < 62 && $item[muculent machete].is_unrestricted())
            {
                //muculent machete
                pullable_item_list.listAppend(GPItemMake($item[muculent machete], "Machete for dense liana", 1));
            }
            else
            {
                //antique machete
                pullable_item_list.listAppend(GPItemMake($item[antique machete], "Machete for dense liana", 1));
            }
        }
    }
	
	//Quest-relevant items:
	
	if (!__quest_state["Level 9"].state_boolean["bridge complete"])
	{
		int boxes_needed = MIN(__quest_state["Level 9"].state_int["bridge fasteners needed"], __quest_state["Level 9"].state_int["bridge lumber needed"]) / 5;
		
		boxes_needed = MIN(3, boxes_needed); //bridge! farming?
		
		if (boxes_needed > 0)
			pullable_item_list.listAppend(GPItemMake($item[smut orc keepsake box], "skip level 9 bridge building", boxes_needed));
	}
	if (!__quest_state["Level 11 Palindome"].finished && $item[mega gem].available_amount() == 0 && ($item[wet stew].available_amount() + $item[wet stunt nut stew].available_amount() + $item[wet stew].creatable_amount() == 0))
		pullable_item_list.listAppend(GPItemMake($item[wet stew], "make into wet stunt nut stew|skip whitey's grove", 1));
    
    if (!__quest_state["Level 13"].state_boolean["Past keys"])
    {
        pullable_item_list.listAppend(GPItemMake($item[star hat], "speed up hole in the sky", 1));
        if ($items[star crossbow, star staff, star sword].available_amount() == 0 && __misc_state["can equip just about any weapon"])
            pullable_item_list.listAppend(GPItemMake($item[star crossbow], "speed up hole in the sky", 1));
	}
    if (__quest_state["Level 11"].mafia_internal_step < 2)
        pullable_item_list.listAppend(GPItemMake($item[blackberry galoshes], "speed up black forest by 2-3? turns", 1));
        
    if (my_path_id() == PATH_HEAVY_RAINS)
        pullable_item_list.listAppend(GPItemMake(lookupItem("fishbone catcher's mitt"), "offhand, less items washing away", 1));
    
        
    //OUTFITS: √Pirate outfit, √War outfit, √Ninja "outfit"
    if (!__quest_state["Level 12"].finished && (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues")))
    {
        item [int] missing_hippy_components = missing_outfit_components("War Hippy Fatigues");
        item [int] missing_frat_components = missing_outfit_components("Frat Warrior Fatigues");
        pullable_item_list.listAppend(GPItemMake("Island War Outfit", "__item round purple sunglasses", "<strong>Hippy</strong>: " + missing_hippy_components.listJoinComponents(", ", "and") + ".|<strong>Frat boy</strong>: " + missing_frat_components.listJoinComponents(", ", "and") + "."));
    }
    
    if (!__quest_state["Level 13"].state_boolean["past gates"] && !gnomads_available())
        pullable_item_list.listAppend(GPItemMake("Unknown gate item", "__item pickle-flavored chewing gum", "Skips south of the border."));
    
    if (!__quest_state["Level 8"].state_boolean["Mountain climbed"] && !have_outfit_components("eXtreme Cold-Weather Gear"))
    {
        item [int] missing_ninja_components = items_missing($items[ninja rope, ninja carabiner, ninja crampons]);
        if (missing_ninja_components.count() > 0)
        {
            string description = missing_ninja_components.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".";
            
            if (numeric_modifier("cold resistance") < 5.0)
                description += "|Will require five " + HTMLGenerateSpanOfClass("cold", "r_element_cold") + " resist to use properly.";
            pullable_item_list.listAppend(GPItemMake("Ninja peak climbing", "__item " + missing_ninja_components[0], description));
        }
    }
    if ($item[talisman o' nam].available_amount() == 0 && !have_outfit_components("Swashbuckling Getup") && $item[pirate fledges].available_amount() == 0 && !__quest_state["Pirate Quest"].finished)
    {
        item [int] missing_outfit_components = missing_outfit_components("Swashbuckling Getup");
        if (missing_outfit_components.count() > 0)
        {
            string entry = missing_outfit_components.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".";
            if ($item[eyepatch].available_amount() == 0)
                entry += "|Or NPZR head/clockwork pirate skull to untinker for eyepatch/clockwork maid.";
            pullable_item_list.listAppend(GPItemMake("Swashbuckling Getup", "__item " + missing_outfit_components[0], entry));
        }
    }
    
    //FIXME suggest machetito?
    //FIXME suggest super marginal stuff in SCO or S&S
    //Ideas: Goat cheese, keepsake box, spooky-gro fertilizer, harem outfit, perfume, rusty hedge trimmers, bowling ball, surgeon gear, tomb ratchets or tangles, all the other pies
    //FIXME suggest ore when we don't have access to free mining
    
    pullable_item_list.listAppend(GPItemMake(lookupItem("duonoculars"), "-combat, +5 ML"));
    if (!__misc_state["can reasonably reach -25% combat"])
        pullable_item_list.listAppend(GPItemMake($item[ring of conflict], "-combat"));
    
	//FIXME suggest guitar if we're out of clovers, we need one, and we've gone past belowdecks already?
	
	pullable_item_list.listAppend(GPItemMake($item[ten-leaf clover], "Turn saving everywhere|Generic pull", 20));
    
    if (get_property_int("lastTempleUnlock") != my_ascensions() && $item[spooky-gro fertilizer].available_amount() == 0)
        pullable_item_list.listAppend(GPItemMake($item[spooky-gro fertilizer], "Saves 2.5 turns while unlocking temple."));
	
	string [int] scrip_reasons;
	int scrip_needed = 0;
	if (!__misc_state["mysterious island available"])
	{
		scrip_needed += 3;
		scrip_reasons.listAppend("mysterious island");
	}
	if ($item[uv-resistant compass].available_amount() == 0 && lookupItem("ornate dowsing rod").available_amount() == 0 && __misc_state["can equip just about any weapon"] && !__quest_state["Level 11 Desert"].state_boolean["Desert Explored"])
	{
		scrip_needed += 1;
		scrip_reasons.listAppend($item[uv-resistant compass].to_string());
	}
	if (scrip_needed > 0)
	{
		pullable_item_list.listAppend(GPItemMake($item[Shore Inc. Ship Trip Scrip], "Saves three turns each|" + scrip_reasons.listJoinComponents(", ", "and").capitalizeFirstLetter() + ".", scrip_needed));
	}
	
	
	boolean currently_trendy = (my_path_id() == PATH_TRENDY);
	foreach key in pullable_item_list
	{
		GPItem gp_item = pullable_item_list[key];
		string reason = gp_item.reason;
		string [int] reason_list = split_string_alternate(reason, "\\|");
		
		if (gp_item.alternate_name != "")
		{
			pulls_entries.listAppend(ChecklistEntryMake(gp_item.alternate_image_name, "storage.php", ChecklistSubentryMake(gp_item.alternate_name, "", reason_list)));
			continue;
		}
		
		
		item [int] items;
		int [item] related_items = get_related(gp_item.it, "fold");
		if (related_items.count() == 0)
			items.listAppend(gp_item.it);
		else
		{
			foreach it in related_items
				items.listAppend(it);
		}
		
		
		int max_wanted = gp_item.max_wanted;
		
        int found_total;
        foreach key in items
        {
			item it = items[key];
            found_total += it.available_amount();
        }
        if (found_total >= max_wanted)
            continue;
		
		foreach key in items
		{
			item it = items[key];
			if (currently_trendy && !is_trendy(it))
				continue;
            if (!is_unrestricted(it))
                continue;
            //if (!it.is_unrestricted()) continue; //FIXME uncomment next point release
			int actual_amount = pullable_amount(it, max_wanted);
			if (actual_amount > 0)
			{
                string url = "storage.php";
                if (it != $item[none])
                {
                    if (it.fullness > 0 || it.inebriety > 0)
                        url = "storage.php?which=1";
                    if (it.to_slot() != $slot[none])
                        url = "storage.php?which=2";
                }
              
                if (it.storage_amount() == 0 && (__pulls_reasonable_to_buy_in_run contains it) && it != $item[ten-leaf clover] && it != $item[none])
                    url = "mall.php";
              
				if (max_wanted == 1)
					pulls_entries.listAppend(ChecklistEntryMake(it, url, ChecklistSubentryMake(it, "", reason_list)));
				else
					pulls_entries.listAppend(ChecklistEntryMake(it, url, ChecklistSubentryMake(pluralize(actual_amount, it), "", reason_list)));
				break;
			}
		}
	}
	
	checklists.listAppend(ChecklistMake("Suggested Pulls", pulls_entries));
}

void PullsInit()
{
    //Pulls which are reasonable to buy in the mall, then pull:
	__pulls_reasonable_to_buy_in_run = $items[peppermint parasol,slimy alveolus,bottle of blank-out,disassembled clover,ten-leaf clover,ninja rope,ninja crampons,ninja carabiner,clockwork maid,sonar-in-a-biscuit,knob goblin perfume,chrome ore,linoleum ore,asbestos ore,goat cheese,enchanted bean,dusty bottle of Marsala,dusty bottle of Merlot,dusty bottle of Muscat,dusty bottle of Pinot Noir,dusty bottle of Port,dusty bottle of Zinfandel,ketchup hound,lion oil,bird rib,stunt nuts,drum machine,beer helmet,distressed denim pants,bejeweled pledge pin,reinforced beaded headband,bullet-proof corduroys,round purple sunglasses,wand of nagamar,ng,star crossbow,star hat,star staff,star sword,Star key lime pie,Boris's key lime pie,Jarlsberg's key lime pie,Sneaky Pete's key lime pie,tomb ratchet,tangle of rat tails,swashbuckling pants,stuffed shoulder parrot,eyepatch,Knob Goblin harem veil,knob goblin harem pants,knob goblin elite polearm,knob goblin elite pants,knob goblin elite helm,cyclops eyedrops,mick's icyvapohotness inhaler,large box,marzipan skull,jaba&ntilde;ero-flavored chewing gum,handsomeness potion,Meleegra&trade; pills,pickle-flavored chewing gum,lime-and-chile-flavored chewing gum,gremlin juice,wussiness potion,Mick's IcyVapoHotness Rub,super-spiky hair gel,adder bladder,black no. 2,skeleton,rock and roll legend,wet stew,glass of goat's milk,hot wing,frilly skirt,pygmy pygment,wussiness potion,gremlin juice,adder bladder,Angry Farmer candy,thin black candle,super-spiky hair gel,Black No. 2,Mick's IcyVapoHotness Rub,Frigid ninja stars,Spider web,Sonar-in-a-biscuit,Black pepper,Pygmy blowgun,Meat vortex,Chaos butterfly,Photoprotoneutron torpedo,Fancy bath salts,inkwell,Hair spray,disease,bronzed locust,Knob Goblin firecracker,powdered organs,leftovers of indeterminate origin,mariachi G-string,NG,plot hole,baseball,razor-sharp can lid,tropical orchid,stick of dynamite,barbed-wire fence,smut orc keepsake box,spooky-gro fertilizer,machetito,muculent machete,antique machete];
}