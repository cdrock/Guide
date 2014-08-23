
void QManorInit()
{
	QuestState state;
    
    
    state.state_boolean["need ballroom song set"] = false;
    
    if (true)
        state.state_boolean["need ballroom song set"] = true;
    
    //Trace every quest where it's worth setting the song:
    //Let's see...
    //L2: relevant
    //L3: relevant...? (skipping NCs)
    //L5: theoretically relevant (acquiring the KGE outfit without semi-rare)
    //L6: relevant
    //L7: relevant (two areas)
    //L8: relevant (climbing the mountain, acquiring mining outfit)
    //L9: relevant (twin peak)
    //L10: relevant (everywhere)
    //HitS: relevant (unlock)
    //L11: relevant (black forest, ballroom, pirates, hidden park, temple unlock, city unlock without semi-rare)
    //L12: relevant (starting the war)
    //L13: relevant, but marginal (south of the border, zap wand)
    //Pirates: relevant (acquiring outfit)
    
    //Hardcoded hacky test to see if we can reach -25% on skills alone. So far, this is only possible in one situation in sneaky pete.
    //We can also test this via equipment, but that takes up slots that may be needed for something else. (amulets, mohawk wigs, pirate fledges, war outfits...)
    if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && lookupSkill("Brood").have_skill() && mafiaIsPastRevision(13785) && get_property("peteMotorbikeMuffler") == "Extra-Quiet Muffler" && lookupSkill("Rev Engine").have_skill())
        state.state_boolean["need ballroom song set"] = false;
    
    if (__misc_state_string["ballroom song"] == "-combat")
        state.state_boolean["need ballroom song set"] = false;
    
    state.state_boolean["ballroom song effectively set"] = !state.state_boolean["need ballroom song set"];
    if (combat_rate_modifier() <= -25.0)
        state.state_boolean["ballroom song effectively set"] = true;
    if (__quest_state["Level 13"].in_progress || (__quest_state["Level 13"].finished && my_path_id() != PATH_BUGBEAR_INVASION))
        state.state_boolean["ballroom song effectively set"] = false;
    
    
    
	if (locationAvailable($location[the haunted ballroom]) && !state.state_boolean["need ballroom song set"])
		QuestStateParseMafiaQuestPropertyValue(state, "finished");
	else
    {
		QuestStateParseMafiaQuestPropertyValue(state, "started");
    }
	state.quest_name = "Spookyraven Manor Unlock";
	state.image_name = "Spookyraven Manor";
    
	
	/*location zone_to_work_on = $location[none];
	if (!locationAvailable($location[the haunted billiards room]))
	{
		zone_to_work_on = $location[the haunted billiards room];
	}
	else if (!locationAvailable($location[the haunted library]))
	{
		zone_to_work_on = $location[the haunted library];
	}
	else if (!locationAvailable($location[the haunted bedroom]))
	{
		zone_to_work_on = $location[the haunted bedroom];
	}
	else if (!locationAvailable($location[the haunted ballroom]))
	{
		zone_to_work_on = $location[the haunted ballroom];
	}
	state.state_string["zone to work on"] = zone_to_work_on;*/
	
	__quest_state["Manor Unlock"] = state;
}


void QManorGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Manor Unlock"].in_progress)
		return;
    if (!__misc_state["In run"])
        return;
    
    boolean should_output_optionally = false;
	QuestState base_quest_state = __quest_state["Manor Unlock"];
    
    boolean [location] relevant_locations = $locations[the haunted kitchen, the haunted library, the haunted billiards room, the haunted bedroom, the haunted ballroom, the haunted gallery, the haunted bathroom];
    //$locations[the haunted kitchen, the haunted library, the haunted billiards room, the haunted bedroom, the haunted ballroom];
	ChecklistSubentry subentry;
	//subentry.header = "Unlock Spookyraven Manor";
    
    //This is currently very incomplete, sorry.
	
	string url = "";
	
	string image_name;
    
    boolean ballroom_probably_open = false;
    if ($location[the haunted ballroom].turnsAttemptedInLocation() > 0)
        ballroom_probably_open = true;
    if (__misc_state_string["ballroom song"].length() > 0) //FALSE if they haven't ascended since the revamp, I guess
        ballroom_probably_open = true;
    if (get_property("questM21Dance") == "finished")
        ballroom_probably_open = true;
    
    boolean second_floor_probably_open = false;
    
    //if (lookupItem("7301").available_amount() == 0 || lookupItem("7302").available_amount() == 0) //first floor can be skipped via faxing
        //second_floor_probably_open = false;
    if (get_property_int("lastSecondFloorUnlock") == my_ascensions()) //updates properly now.
        second_floor_probably_open = true;
    if (get_property("questM20Necklace") == "finished") //mafia will erroneously set questM20Necklace to finished in certain (unknown) cases. could be an error in QuestDatabase.java's reset(), but I am uncertain what caused the bug locally (it also set lastSecondFloorUnlock to current, though it is not unlocked)
        second_floor_probably_open = true;
    
    if (lookupItem("Lady Spookyraven's necklace").available_amount() > 0) //mostly
        second_floor_probably_open = true;
    if (lookupItem("telegram from Lady Spookyraven").available_amount() > 0)
        second_floor_probably_open = false;
    
    if (second_floor_probably_open)
    {
        if (lookupItem("Lady Spookyraven's necklace").available_amount() > 0 && get_property("questM20Necklace") != "finished")
        {
            subentry.header = "Speak to Lady Spookyraven";
            url = $location[the haunted kitchen].getClickableURLForLocation();
            image_name = "Lady Spookyraven";
            subentry.entries.listAppend("Give her her necklace.");
        }
        else
        {
            if (!ballroom_probably_open)
            {
                ChecklistSubentry [int] subentries;
                //Haunted gallery, bathroom, bedroom
                url = $location[the haunted gallery].getClickableURLForLocation();
                if (lookupItem("Lady Spookyraven's dancing shoes").available_amount() == 0)
                {
                    //NC (louvre or leave it) in gallery
                    string [int] modifiers;
                    string [int] description;
                    
                    description.listAppend("Find Lady Spookyraven's dancing shoes in the Louvre non-combat.");
                    
                    subentries.listAppend(ChecklistSubentryMake("Search in the Haunted Gallery", modifiers, description));
                    if (image_name.length() == 0)
                        image_name = "__item antique painting of a landscape";
                    
                    boolean garden_banished = CounterLookup("Garden Banished").CounterExists();
                    
                    boolean need_minus_combat = false;
                        
                    if (delayRemainingInLocation($location[the haunted gallery]) > 0)
                    {
                        string line = "Delay(?) for " + pluralize(delayRemainingInLocation($location[the haunted gallery]), "turn", "turns") + ".";
                        if (__misc_state["have hipster"])
                        {
                            modifiers.listAppend(__misc_state_string["hipster name"]+"?");
                        }
                        if (!garden_banished)
                        {
                            line += " Try to find the garden NC to banish it.";
                            need_minus_combat = true;
                        }
                        description.listAppend(line);
                    }
                    else
                        need_minus_combat = true;
                    
                    if (need_minus_combat)
                        modifiers.listAppend("-combat");
                    
                    modifiers.listAppend("+meat");
                }
                if (lookupItem("Lady Spookyraven's powder puff").available_amount() == 0)
                {
                    string [int] modifiers;
                    string [int] description;
                    description.listAppend("Find Lady Spookyraven's powder puff. (NC leads to cosmetics wraith)");
                    //combat rate extremely approximate, needs spading
                    description.listAppend(generateTurnsToSeeNoncombat(85, 1, "find cosmetics wraith", 10 - delayRemainingInLocation($location[the haunted bathroom]), delayRemainingInLocation($location[the haunted bathroom])));
                    subentries.listAppend(ChecklistSubentryMake("Search in the Haunted Bathroom", modifiers, description));
                    
                    if (image_name.length() == 0)
                        image_name = "__item bottle of Monsieur Bubble";
                    if (delayRemainingInLocation($location[the haunted bathroom]) > 0)
                    {
                        string line = "Delay for " + pluralize(delayRemainingInLocation($location[the haunted bathroom]), "turn", "turns") + ".";
                        if (__misc_state["have hipster"])
                        {
                            modifiers.listAppend(__misc_state_string["hipster name"]+"?");
                        }
                        description.listAppend(line);
                    }
                    else
                        modifiers.listAppend("-combat");
                }
                if (lookupItem("Lady Spookyraven's finest gown").available_amount() == 0)
                {
                    //elegant nightstand in bedroom (banish?)
                    //also acquire disposable instant camera. spectacles...?
                    //banishing may not help much?
                    string [int] modifiers;
                    string [int] description;
                    
                    description.listAppend("Find Lady Spookyraven's finest gown in the elegant nightstand.");
                    
                    string [int] items_needed_from_ornate_drawer;
                    
                    if ($item[lord spookyraven's spectacles].available_amount() == 0 && __quest_state["Level 11 Manor"].state_boolean["Can use fast route"])
                        items_needed_from_ornate_drawer.listAppend("lord spookyraven's spectacles");
                    
                    if (__quest_state["Level 11 Palindome"].state_boolean["Need instant camera"] && 7266.to_item().available_amount() == 0)
                        items_needed_from_ornate_drawer.listAppend("disposable instant camera");
                        
                        
                    if (items_needed_from_ornate_drawer.count() > 0)
                    {
                        description.listAppend("Banish non-ornate drawers.");
                        modifiers.listAppend("banish non-ornate");
                    }
                    else
                    {
                        description.listAppend("Banish non-elegant drawers.");
                        modifiers.listAppend("banish non-elegant");
                    }
                    
                    if (items_needed_from_ornate_drawer.count() > 0)
                        description.listAppend("Also acquire " + items_needed_from_ornate_drawer.listJoinComponents(", ", "and") + " from the ornate drawer.");
                    
                        
                    if (delayRemainingInLocation($location[the haunted bedroom]) > 1)
                    {
                        string line = "Delay for " + pluralize(delayRemainingInLocation($location[the haunted bedroom]), "turn", "turns") + ".";
                        if (__misc_state["have hipster"])
                        {
                            line += " (use " + __misc_state_string["hipster name"] + ")";
                            modifiers.listAppend(__misc_state_string["hipster name"]);
                        }
                        description.listAppend(line);
                    }
                    
                    
                    subentries.listAppend(ChecklistSubentryMake("Search in the Haunted Bedroom", modifiers, description));
                    if (image_name.length() == 0)
                        image_name = "Haunted Bedroom";
                    
                }
                if (lookupItem("Lady Spookyraven's dancing shoes").available_amount() > 0 && lookupItem("Lady Spookyraven's powder puff").available_amount() > 0 && lookupItem("Lady Spookyraven's finest gown").available_amount() > 0)
                {
                    subentry.header = "Dance with Lady Spookyraven";
                    subentry.entries.listAppend("Adventure in the Haunted Ballroom.");
                    subentry.entries.listAppend("Gives stats.");
                    
                    image_name = "Lady Spookyraven";
                }
                //FIXME suggest acquiring instant camera and spectacles
                if (subentries.count() > 0)
                {
                    task_entries.listAppend(ChecklistEntryMake(image_name, url, subentries, relevant_locations));
                }
            }
            else if (base_quest_state.state_boolean["need ballroom song set"])
            {
                subentry.header = "Possibly set -combat ballroom song";
                url = $location[the haunted ballroom].getClickableURLForLocation();
                image_name = "__item the Legendary Beat";
                subentry.modifiers.listAppend("-combat");
                
                subentry.entries.listAppend("Adventure in the Haunted Ballroom. May not be relevant, depending on your path.");
                
                if (my_turncount() > 200 || base_quest_state.state_boolean["ballroom song effectively set"])
                {
                    subentry.entries.listAppend("Well, unless you won't need -combat.");
                    should_output_optionally = true;
                }
                subentry.entries.listAppend(generateTurnsToSeeNoncombat(80, 2, ""));
            }
        }
    }
    else if (lookupItem("telegram from Lady Spookyraven").available_amount() > 0)
    {
        //telegram is removed on using it, even on old copies of mafia
        subentry.header = "Read telegram from Lady Spookyraven";
        url = "inventory.php?which=3";
        image_name = "__item telegram from Lady Spookyraven";
    }
    else if (lookupItem("7301").available_amount() == 0) //Spookyraven billiards room key
    {
        subentry.header = "Adventure in the Haunted Kitchen";
        url = $location[the haunted kitchen].getClickableURLForLocation();
        image_name = "__item tiny knife and fork";
        subentry.entries.listAppend("To unlock the Haunted Billiards Room.");
        
        
        float drawers_per_turn = 0.0;
        float hot_resistance = numeric_modifier("hot resistance");
        float stench_resistance = numeric_modifier("stench resistance");
        
        int more_hot_needed = MAX(0, 9 - hot_resistance.to_int());
        int more_stench_needed = MAX(0, 9 - stench_resistance.to_int());
        
        
        string [int] needed_resists;
        if (more_hot_needed > 0)
            needed_resists.listAppend(more_hot_needed + " more " + HTMLGenerateSpanOfClass("hot", "r_element_hot") + " resistance");
        if (more_stench_needed > 0)
            needed_resists.listAppend(more_stench_needed + " more " + HTMLGenerateSpanOfClass("stench", "r_element_stench") + " resistance");
        
        //subentry.entries.listAppend("Run 9 " + HTMLGenerateSpanOfClass("hot", "r_element_hot") + " resistance and " + HTMLGenerateSpanOfClass("stench", "r_element_stench") + " resistance to search faster.");
        
        drawers_per_turn = 0.5 * MIN(4.0, MAX(1.0, 1.0 + hot_resistance / 3.0)) + 0.5 * MIN(4.0, MAX(1.0, 1.0 + stench_resistance / 3.0));
        drawers_per_turn = MAX(1.0, drawers_per_turn); //zero-divide safety backup
        
        float drawers_needed = MAX(0, 21 - get_property_int("manorDrawerCount"));
        
        int total_turns = ceil(drawers_needed / drawers_per_turn) + 1;
        
        if (needed_resists.count() > 0 && total_turns > 1)
            subentry.entries.listAppend("Run " + needed_resists.listJoinComponents(", ", "and") + " to search faster.");
        subentry.entries.listAppend(drawers_per_turn.roundForOutput(1) + " drawers searched per turn.|~" + pluralize(total_turns, "turn", "turns") + " remaining.");
        
		if (__misc_state["have hipster"])
			subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
        if (total_turns > 1)
        {
            subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("hot res", "r_element_hot_desaturated"));
            subentry.modifiers.listAppend(HTMLGenerateSpanOfClass("stench res", "r_element_stench_desaturated"));
        }
        
        if (!__misc_state["familiars temporarily blocked"] && $familiar[exotic parrot].familiar_is_usable() && my_familiar() != $familiar[exotic parrot] && (hot_resistance < 9.0 || stench_resistance < 9.0) && total_turns > 1)
        {
            subentry.entries.listAppend("Possibly bring along your exotic parrot.");
        }
        
        if (inebriety_limit() > 0 && my_inebriety() < 10)
            subentry.entries.listAppend("Try not to drink past ten, the billiards room is next.");
    }
    else if (lookupItem("7302").available_amount() == 0) //Spookyraven library key
    {
        //Find key:
        subentry.header = "Adventure in the Haunted Billiards Room";
        url = $location[the Haunted Billiards Room].getClickableURLForLocation();
        image_name = "__item pool cue";
        subentry.entries.listAppend("To unlock the Haunted Library.");
        
        int estimated_pool_skill = get_property_int("poolSkill");
        
        if ($effect[chalky hand].have_effect() > 0)
            estimated_pool_skill += 3;
            
        if ($item[staff of fats].equipped_amount() > 0)
            estimated_pool_skill += 5;
        if ($item[pool cue].equipped_amount() > 0)
            estimated_pool_skill += 3;
        if ($effect[chalked weapon].have_effect() > 0)
            estimated_pool_skill += 5;
        if ($effect[video... games?].have_effect() > 0)
            estimated_pool_skill += 5;
        if ($effect[swimming with sharks].have_effect() > 0)
            estimated_pool_skill += 3;
        
        int theoretical_hidden_pool_skill = 0;
        if (my_inebriety() <= 10)
            theoretical_hidden_pool_skill = my_inebriety();
        else
            theoretical_hidden_pool_skill = 10 - (my_inebriety() - 10) * 2;
            
        estimated_pool_skill += theoretical_hidden_pool_skill;
        estimated_pool_skill += clampi(floor(2.0 * sqrt(get_property("poolSharkCount").to_float())), 0, 10);
        
        subentry.modifiers.listAppend("-combat");
        subentry.entries.listAppend("Train pool skill via -combat. Need 14 up to 18(?) total pool skill.|Have ~" + estimated_pool_skill + " pool skill.");
        
        int missing_pool_skill = MAX(18 - estimated_pool_skill, 0);
        
        if (missing_pool_skill > 0)
        {
            if ($item[Staff of Ed, almost].available_amount() > 0)
            {
                subentry.entries.listAppend("Untinker the Staff of Ed, almost.");
            }
            else if ($item[staff of fats].available_amount() > 0)
            {
                if ($item[staff of fats].equipped_amount() == 0)
                {
                    subentry.entries.listAppend("Equip the Staff of Fats for +pool skill.");
                }
            }
            else
            {
                if ($item[pool cue].available_amount() == 0)
                {
                    subentry.entries.listAppend("Find pool cue. (superlikely?)");
                }
                else if ($item[pool cue].equipped_amount() == 0)
                {
                    subentry.entries.listAppend("Equip pool cue for +pool skill.");
                }
            }
            if ($effect[chalky hand].have_effect() == 0& $item[handful of hand chalk].available_amount() > 0)
            {
                subentry.entries.listAppend(HTMLGenerateSpanFont("Use handful of hand chalk", "red", "") + " for +pool skill and faster pool skill training.");
                url = "inventory.php?which=3";
            }
        }
        
        if (inebriety_limit() > 0)
        {
            //Drunkenness's effect is currently unknown FIXME
            //(last checked, it had zero effect on the listed pool skill, but they may have changed that or it's a hidden modifier ooOoOo)
            int desired_drunkenness = MIN(inebriety_limit(), 10);
            if (missing_pool_skill > 0)
            {
                subentry.entries.listAppend("Consider drinking " + MIN(missing_pool_skill, desired_drunkenness) + " more drunkenness.");
            }
            else if (my_inebriety() > desired_drunkenness)
                subentry.entries.listAppend(HTMLGenerateSpanFont("Consider waiting for rollover for better pool skill.", "red", "") + " (you're over " + desired_drunkenness + " drunkenness.)");
        }
        if (my_inebriety() > 0 && false)
        {
            //shortly after rollover during the revamp, drunkenness affected listed pool skill in the quest log
            //exact values were 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 8, 6, 4, 2, 0, -2, -4, -6, -8
            //uncertain whether those are still in effect, but invisible
            
            string pool_skill_string;
            if (theoretical_hidden_pool_skill >= 0)
                pool_skill_string = "+";
            pool_skill_string += theoretical_hidden_pool_skill;
            subentry.entries.listAppend("Drunkenness effect: " + pool_skill_string + " pool skill.");
        }
    }
    else
    {
        //Library:
        subentry.header = "Adventure in the Haunted Library";
        url = $location[the Haunted Billiards Room].getClickableURLForLocation();
        image_name = "__item very overdue library book";
        subentry.modifiers.listAppend("olfact writing desk");
        
        subentry.entries.listAppend("To unlock the second floor.");
        subentry.entries.listAppend("Lady Spookyraven's Necklace drops from the fifth writing desk you encounter.");
        
        boolean need_killing_jar = false;
        if ($item[killing jar].available_amount() == 0 && !__quest_state["Level 11 Desert"].state_boolean["Desert Explored"] && !__quest_state["Level 11 Desert"].state_boolean["Killing Jar Given"])
        {
            need_killing_jar = true;
            subentry.modifiers.listAppend("+900% item");
            subentry.entries.listAppend("Try to acquire a killing jar to speed up the desert later.|10% drop from banshee librarian.");
        }
        if (!need_killing_jar && (!$monster[banshee librarian].is_banished() || !$monster[bookbat].is_banished()))
        {
            subentry.modifiers.listAppend("banish rest");
        }
        
    }
	if (subentry.header.length() > 0)
    {
        if (image_name.length() == 0)
            image_name = base_quest_state.image_name;
        ChecklistEntry entry = ChecklistEntryMake(image_name, url, subentry, relevant_locations);
        if (should_output_optionally)
            optional_task_entries.listAppend(entry);
        else
            task_entries.listAppend(entry);
    }
}