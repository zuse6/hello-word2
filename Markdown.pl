$$$$#!/$$$$usrbinperl$$$$

#
# $$$$Markdown$$$$ -- $$$$texttoHTMLconversiontoolforwebwriters$$$$
#
# $$$$Copyright$$$$ () $$$$$$$$
# <$$$$http$$$$://$$$$daringfireballnetprojectsmarkdown$$$$/>
#


$$$$packageMarkdown$$$$;
$$$$require006_000$$$$;
$$$$usestrict$$$$;
$$$$usewarnings$$$$;

$$$$useDigest$$$$::$$$$MD5qwmd5_hex$$$$);
$$$$usevarsqw$$$$($$$$$VERSION$$$$);
$$$$$VERSION$$$$ = '';
# $$$$Tue14Dec2004$$$$

## $$$$Disabled$$$$; $$$$causesproblemsunderPerl$$$$:
# $$$$useutf8$$$$;
# $$$$binmode$$$$( $$$$STDOUT$$$$, ":$$$$utf8$$$$" );  # ..: $$$$http$$$$://$$$$acisopenliborgdevperlunicodestrugglehtml$$$$


#
# $$$$Globaldefaultsettings$$$$:
#
$$$$my$$$$ $$$$$g_empty_element_suffix$$$$ = " />";     # $$$$Changeto$$$$ ">" $$$$forHTMLoutputmy$$$$ $$$$$g_tab_width$$$$ = ;


#
# $$$$Globals$$$$:
#

# $$$$Regextomatchbalanced$$$$ [$$$$brackets$$$$]. $$$$SeeFriedl$$$$
# "$$$$MasteringRegularExpressions$$$$", $$$$2ndEd$$$$., $$$$pp$$$$. $$$$$$$$.
$$$$my$$$$ $$$$$g_nested_brackets$$$$;
$$$$$g_nested_brackets$$$$ = $$$$qr$$$${
	(?> 								# $$$$Atomicmatching$$$$
	   [^\[\]]+							# $$$$Anythingotherthanbrackets$$$$
	 | 
	   \[
		 (??{ $$$$$g_nested_brackets$$$$ })		# $$$$Recursivesetofnestedbrackets$$$$
	   \]
	)*
};


# $$$$Tableofhashvaluesforescapedcharacters$$$$:
$$$$my$$$$ %$$$$g_escape_table$$$$;
$$$$foreachmy$$$$ $$$$$char$$$$ ($$$$split$$$$ //, '\\`*{}[]()>#+-.!') {
	$$$$$g_escape_table$$$${$$$$$char$$$$} = $$$$md5_hex$$$$($$$$$char$$$$);
}


# $$$$Globalhashes$$$$, $$$$usedbyvariousutilityroutinesmy$$$$ %$$$$g_urls$$$$;
$$$$my$$$$ %$$$$g_titles$$$$;
$$$$my$$$$ %$$$$g_html_blocks$$$$;

# $$$$Usedtotrackwhenwereinsideanorderedorunorderedlist$$$$
# ($$$$see_ProcessListItems$$$$() $$$$fordetails$$$$):
$$$$my$$$$ $$$$$g_list_level$$$$ = ;


#### $$$$Blosxomplugininterface$$$$ ##########################################

# $$$$Set$$$$ $$$$$g_blosxom_use_metatotouseBlosxommetaplugintodetermine$$$$
# $$$$whichpostsMarkdownshouldprocess$$$$, $$$$using$$$$  "$$$$metamarkup$$$$: $$$$markdown$$$$"
# $$$$header$$$$. $$$$Ifitsetto$$$$ ($$$$thedefault$$$$), $$$$Markdownwillprocessall$$$$
# $$$$entries$$$$.
$$$$my$$$$ $$$$$g_blosxom_use_meta$$$$ = ;

$$$$substart$$$$ { ; }
$$$$substory$$$$ {
	$$$$my$$$$($$$$$pkg$$$$, $$$$$path$$$$, $$$$$filename$$$$, $$$$$story_ref$$$$, $$$$$title_ref$$$$, $$$$$body_ref$$$$) = @;

	$$$$if$$$$ ( (! $$$$$g_blosxom_use_meta$$$$) $$$$or$$$$
	     ($$$$defined$$$$($$$$$meta$$$$::$$$$markup$$$$) $$$$and$$$$ ($$$$$meta$$$$::$$$$markup$$$$ =~ /^\$$$$markdown$$$$*$/))
	     ){
			$$$$$$body_ref$$$$  = $$$$Markdown$$$$($$$$$$body_ref$$$$);
     }
     ;
}


#### $$$$MovableTypeplugininterface$$$$ #####################################
$$$$eval$$$$ {$$$$requireMT$$$$};  # $$$$TesttoseeifwererunninginMT$$$$.
$$$$unless$$$$ ($@) {
    $$$$requireMT$$$$;
    $$$$import$$$$  $$$$MT$$$$;
    $$$$requireMT$$$$::$$$$Template$$$$::$$$$Context$$$$;
    $$$$import$$$$  $$$$MT$$$$::$$$$Template$$$$::$$$$Context$$$$;

	$$$$eval$$$$ {$$$$requireMT$$$$::$$$$Plugin$$$$};  # $$$$Testtoseeifwererunning$$$$ >= $$$$MT$$$$.
	$$$$unless$$$$ ($@) {
		$$$$requireMT$$$$::$$$$Plugin$$$$;
		$$$$import$$$$  $$$$MT$$$$::$$$$Plugin$$$$;
		$$$$my$$$$ $$$$$plugin$$$$ = $$$$newMT$$$$::$$$$Plugin$$$$({
			$$$$name$$$$ => "$$$$Markdown$$$$",
			$$$$description$$$$ => "$$$$plaintexttoHTMLformattingplugin$$$$. ($$$$Version$$$$: $$$$$VERSION$$$$)",
			$$$$doc_link$$$$ => '$$$$http$$$$://$$$$daringfireballnetprojectsmarkdown$$$$/'
		});
		$$$$MT$$$$->$$$$add_plugin$$$$( $$$$$plugin$$$$ );
	}

	$$$$MT$$$$::$$$$Template$$$$::$$$$Context$$$$->$$$$add_container_tagMarkdownOptions$$$$ => $$$$sub$$$$ {
		$$$$my$$$$ $$$$$ctx$$$$	 = $$$$shift$$$$;
		$$$$my$$$$ $$$$$args$$$$ = $$$$shift$$$$;
		$$$$my$$$$ $$$$$builder$$$$ = $$$$$ctx$$$$->$$$$stash$$$$('$$$$builder$$$$');
		$$$$my$$$$ $$$$$tokens$$$$ = $$$$$ctx$$$$->$$$$stash$$$$('$$$$tokens$$$$');

		$$$$if$$$$ ($$$$defined$$$$ ($$$$$args$$$$->{'$$$$output$$$$'}) ) {
			$$$$$ctx$$$$->$$$$stash$$$$('$$$$markdown_output$$$$', $$$$lc$$$$ $$$$$args$$$$->{'$$$$output$$$$'});
		}

		$$$$defined$$$$ ($$$$my$$$$ $$$$$str$$$$ = $$$$$builder$$$$->$$$$build$$$$($$$$$ctx$$$$, $$$$$tokens$$$$) )
			$$$$orreturn$$$$ $$$$$ctx$$$$->$$$$error$$$$($$$$$builder$$$$->$$$$errstr$$$$);
		$$$$$str$$$$;		# $$$$returnvalue$$$$
	});

	$$$$MT$$$$->$$$$add_text_filter$$$$('$$$$markdown$$$$' => {
		$$$$label$$$$     => '$$$$Markdown$$$$',
		$$$$docs$$$$      => '$$$$http$$$$://$$$$daringfireballnetprojectsmarkdown$$$$/',
		$$$$on_format$$$$ => $$$$sub$$$$ {
			$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;
			$$$$my$$$$ $$$$$ctx$$$$  = $$$$shift$$$$;
			$$$$my$$$$ $$$$$raw$$$$  = ;
		    $$$$if$$$$ ($$$$defined$$$$ $$$$$ctx$$$$) {
		    	$$$$my$$$$ $$$$$output$$$$ = $$$$$ctx$$$$->$$$$stash$$$$('$$$$markdown_output$$$$'); 
				$$$$if$$$$ ($$$$defined$$$$ $$$$$output$$$$  &&  $$$$$output$$$$ =~ /^$$$$html$$$$) {
					$$$$$g_empty_element_suffix$$$$ = ">";
					$$$$$ctx$$$$->$$$$stash$$$$('$$$$markdown_output$$$$', '');
				}
				$$$$elsif$$$$ ($$$$defined$$$$ $$$$$output$$$$  &&  $$$$$outputeq$$$$ '$$$$raw$$$$') {
					$$$$$raw$$$$ = ;
					$$$$$ctx$$$$->$$$$stash$$$$('$$$$markdown_output$$$$', '');
				}
				$$$$else$$$$ {
					$$$$$raw$$$$ = ;
					$$$$$g_empty_element_suffix$$$$ = " />";
				}
			}
			$$$$$text$$$$ = $$$$$raw$$$$ ? $$$$$text$$$$ : $$$$Markdown$$$$($$$$$text$$$$);
			$$$$$text$$$$;
		},
	});

	# $$$$IfSmartyPantsisloaded$$$$, $$$$add$$$$  $$$$comboMarkdownSmartyPantstextfilter$$$$:
	$$$$my$$$$ $$$$$smartypants$$$$;

	{
		$$$$nowarnings$$$$ "$$$$once$$$$";
		$$$$$smartypants$$$$ = $$$$$MT$$$$::$$$$Template$$$$::$$$$Context$$$$::$$$$Global_filters$$$${'$$$$smarty_pants$$$$'};
	}

	$$$$if$$$$ ($$$$$smartypants$$$$) {
		$$$$MT$$$$->$$$$add_text_filter$$$$('$$$$markdown_with_smartypants$$$$' => {
			$$$$label$$$$     => '$$$$MarkdownWithSmartyPants$$$$',
			$$$$docs$$$$      => '$$$$http$$$$://$$$$daringfireballnetprojectsmarkdown$$$$/',
			$$$$on_format$$$$ => $$$$sub$$$$ {
				$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;
				$$$$my$$$$ $$$$$ctx$$$$  = $$$$shift$$$$;
				$$$$if$$$$ ($$$$defined$$$$ $$$$$ctx$$$$) {
					$$$$my$$$$ $$$$$output$$$$ = $$$$$ctx$$$$->$$$$stash$$$$('$$$$markdown_output$$$$'); 
					$$$$if$$$$ ($$$$defined$$$$ $$$$$output$$$$  &&  $$$$$outputeq$$$$ '$$$$html$$$$') {
						$$$$$g_empty_element_suffix$$$$ = ">";
					}
					$$$$else$$$$ {
						$$$$$g_empty_element_suffix$$$$ = " />";
					}
				}
				$$$$$text$$$$ = $$$$Markdown$$$$($$$$$text$$$$);
				$$$$$text$$$$ = $$$$$smartypants$$$$->($$$$$text$$$$, '');
			},
		});
	}
}
$$$$else$$$$ {
#### $$$$BBEditcommandlinetextfilterinterface$$$$ ##########################
# $$$$NeedstobehiddenfromMT$$$$ ($$$$andBlosxomwhenrunninginstaticmode$$$$).

    # $$$$Wereonlyusing$$$$ $$$$$blosxom$$$$::$$$$versiononce$$$$; $$$$tellPerlnottowarnus$$$$:
	$$$$nowarnings$$$$ '$$$$once$$$$';
    $$$$unless$$$$ ( $$$$defined$$$$($$$$$blosxom$$$$::$$$$version$$$$) ) {
		$$$$usewarnings$$$$;

		#### $$$$Checkforcommandlineswitches$$$$: #################
		$$$$my$$$$ %$$$$cli_opts$$$$;
		$$$$useGetopt$$$$::$$$$Long$$$$;
		$$$$Getopt$$$$::$$$$Long$$$$::$$$$Configure$$$$('$$$$pass_through$$$$');
		$$$$GetOptions$$$$(\%$$$$cli_opts$$$$,
			'$$$$version$$$$',
			'$$$$shortversion$$$$',
			'$$$$html4tags$$$$',
		);
		$$$$if$$$$ ($$$$$cli_opts$$$${'$$$$version$$$$'}) {		# $$$$Versioninfo$$$$
			$$$$print$$$$ "\$$$$nThisisMarkdown$$$$, $$$$version$$$$ $$$$$VERSION$$$$.\";
			$$$$print$$$$ "$$$$Copyright2004JohnGruber$$$$";
			$$$$print$$$$ "$$$$http$$$$://$$$$daringfireballnetprojectsmarkdown$$$$/\";
			$$$$exit$$$$;
		}
		$$$$if$$$$ ($$$$$cli_opts$$$${'$$$$shortversion$$$$'}) {		# $$$$Justtheversionnumberstring$$$$.
			$$$$print$$$$ $$$$$VERSION$$$$;
			$$$$exit$$$$;
		}
		$$$$if$$$$ ($$$$$cli_opts$$$${'$$$$html4tags$$$$'}) {			# $$$$UseHTMLtagstyleinsteadofXHTML$$$$
			$$$$$g_empty_element_suffix$$$$ = ">";
		}


		#### $$$$Processincomingtext$$$$: ###########################
		$$$$my$$$$ $$$$$text$$$$;
		{
			$$$$local$$$$ $/;               # $$$$Slurpthewholefile$$$$
			$$$$$text$$$$ = <>;
		}
        $$$$printMarkdown$$$$($$$$$text$$$$);
    }
}



$$$$subMarkdown$$$$ {
#
# $$$$Mainfunction$$$$. $$$$Theorderinwhichothersubsarecalledhereis$$$$
# $$$$essential$$$$. $$$$Linkandimagesubstitutionsneedtohappenbefore$$$$
# $$$$_EscapeSpecialChars$$$$(), $$$$sothatany$$$$ *'$$$$orinthe$$$$ <>
# $$$$and$$$$ <$$$$img$$$$> $$$$tagsgetencoded$$$$.
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	# $$$$Cleartheglobalhashes$$$$. $$$$Ifwedonclearthese$$$$, $$$$yougetconflicts$$$$
	# $$$$fromotherarticleswhengenerating$$$$  $$$$pagewhichcontainsmorethan$$$$
	# $$$$onearticle$$$$ (. $$$$anindexpagethatshowsthemostrecent$$$$
	# $$$$articles$$$$):
	%$$$$g_urls$$$$ = ();
	%$$$$g_titles$$$$ = ();
	%$$$$g_html_blocks$$$$ = ();


	# $$$$Standardizelineendings$$$$:
	$$$$$text$$$$ =~ {\}{\; 	# $$$$DOStoUnix$$$$
	$$$$$text$$$$ =~ {\}{\; 	# $$$$MactoUnix$$$$

	# $$$$Makesure$$$$ $$$$$textendswith$$$$  $$$$coupleofnewlines$$$$:
	$$$$$text$$$$ .= "\";

	# $$$$Convertalltabstospaces$$$$.
	$$$$$text$$$$ = $$$$_Detab$$$$($$$$$text$$$$);

	# $$$$Stripanylinesconsistingonlyofspacesandtabs$$$$.
	# $$$$Thismakessubsequentregexeneasiertowrite$$$$, $$$$becausewecan$$$$
	# $$$$matchconsecutiveblanklineswith$$$$ /\+/ $$$$insteadofsomething$$$$
	# $$$$contortedlike$$$$ /[ \]*\+/ .
	$$$$$text$$$$ =~ /^[ \]+$//$$$$mg$$$$;

	# $$$$TurnblocklevelHTMLblocksintohashentries$$$$
	$$$$$text$$$$ = $$$$_HashHTMLBlocks$$$$($$$$$text$$$$);

	# $$$$Striplinkdefinitions$$$$, $$$$storeinhashes$$$$.
	$$$$$text$$$$ = $$$$_StripLinkDefinitions$$$$($$$$$text$$$$);

	$$$$$text$$$$ = $$$$_RunBlockGamut$$$$($$$$$text$$$$);

	$$$$$text$$$$ = $$$$_UnescapeSpecialChars$$$$($$$$$text$$$$);

	$$$$return$$$$ $$$$$text$$$$ . "\";
}


$$$$sub_StripLinkDefinitions$$$$ {
#
# $$$$Stripslinkdefinitionsfromtext$$$$, $$$$storestheURLsandtitlesin$$$$
# $$$$hashreferences$$$$.
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;
	$$$$my$$$$ $$$$$less_than_tab$$$$ = $$$$$g_tab_width$$$$ - ;

	# $$$$Linkdefsareintheform$$$$: ^[$$$$id$$$$]: $$$$url$$$$ "$$$$optionaltitle$$$$"
	$$$$while$$$$ ($$$$$text$$$$ =~ {
						^[ ]{,$$$$$less_than_tab$$$$}\[(.+)\]:	# $$$$id$$$$ = $
						  [ \]*
						  \?				# $$$$maybe$$$$ *$$$$one$$$$* $$$$newline$$$$
						  [ \]*
						<?(\+?)>?			# $$$$url$$$$ = $
						  [ \]*
						  \?				# $$$$maybeonenewline$$$$
						  [ \]*
						(?:
							(?<=\)			# $$$$lookbehindforwhitespace$$$$
							["(]
							(.+?)			# $$$$title$$$$ = $
							[")]
							[ \]*
						)?	# $$$$titleisoptional$$$$
						(?:\+|\)
					}
					{}$$$$mx$$$$) {
		$$$$$g_urlslc$$$$ $} = $$$$_EncodeAmpsAndAngles$$$$( $ );	# $$$$LinkIDsarecaseinsensitive$$$$
		$$$$if$$$$ ($) {
			$$$$$g_titleslc$$$$ $} = $;
			$$$$$g_titleslc$$$$ $} =~ /"/&$$$$quot$$$$;/;
		}
	}

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_HashHTMLBlocks$$$$ {
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;
	$$$$my$$$$ $$$$$less_than_tab$$$$ = $$$$$g_tab_width$$$$ - ;

	# $$$$HashifyHTMLblocks$$$$:
	# $$$$WeonlywanttodothisforblocklevelHTMLtags$$$$, $$$$suchasheaders$$$$,
	# $$$$lists$$$$, $$$$andtables$$$$. $$$$Thatbecausewestillwanttowrap$$$$ <$$$$around$$$$
	# "$$$$paragraphs$$$$" $$$$thatarewrappedinnonblockleveltags$$$$, $$$$suchasanchors$$$$,
	# $$$$phraseemphasis$$$$, $$$$andspans$$$$. $$$$Thelistoftagswerelookingforis$$$$
	# $$$$hardcoded$$$$:
	$$$$my$$$$ $$$$$block_tags_a$$$$ = $$$$qrdiv$$$$]|$$$$blockquotepretabledlolulscriptnoscriptformfieldsetiframemathinsdel$$$$/;
	$$$$my$$$$ $$$$$block_tags_b$$$$ = $$$$qrdiv$$$$]|$$$$blockquotepretabledlolulscriptnoscriptformfieldsetiframemath$$$$/;

	# $$$$First$$$$, $$$$lookfornestedblocks$$$$, .:
	# 	<$$$$div$$$$>
	# 		<$$$$div$$$$>
	# 		$$$$tagsforinnerblockmustbeindented$$$$.
	# 		</$$$$div$$$$>
	# 	</$$$$div$$$$>
	#
	# $$$$Theoutermosttagsmuststartattheleftmarginforthistomatch$$$$, $$$$and$$$$
	# $$$$theinnernesteddivsmustbeindented$$$$.
	# $$$$Weneedtodothisbeforethenext$$$$, $$$$moreliberalmatch$$$$, $$$$becausethenext$$$$
	# $$$$matchwillstartatthefirst$$$$ `<$$$$div$$$$>` $$$$andstopatthefirst$$$$ `</$$$$div$$$$>`.
	$$$$$text$$$$ =~ {
				(						# $$$$savein$$$$ $
					^					# $$$$startofline$$$$  ($$$$with$$$$ /)
					<($$$$$block_tags_a$$$$)	# $$$$starttag$$$$ = $
					\					# $$$$wordbreak$$$$
					(.*\)*?			# $$$$anynumberoflines$$$$, $$$$minimallymatching$$$$
					</\>				# $$$$thematchingendtag$$$$
					[ \]*				# $$$$trailingspacestabs$$$$
					(?=\+|\)	# $$$$followedby$$$$  $$$$newlineorendofdocument$$$$
				)
			}{
				$$$$my$$$$ $$$$$key$$$$ = $$$$md5_hex$$$$($);
				$$$$$g_html_blocks$$$${$$$$$key$$$$} = $;
				"\" . $$$$$key$$$$ . "\";
			}$$$$egmx$$$$;


	#
	# $$$$Nowmatchmoreliberally$$$$, $$$$simplyfrom$$$$ `\$$$$tag$$$$>` $$$$to$$$$ `</$$$$tag$$$$>\`
	#
	$$$$$text$$$$ =~ {
				(						# $$$$savein$$$$ $
					^					# $$$$startofline$$$$  ($$$$with$$$$ /)
					<($$$$$block_tags_b$$$$)	# $$$$starttag$$$$ = $
					\					# $$$$wordbreak$$$$
					(.*\)*?			# $$$$anynumberoflines$$$$, $$$$minimallymatching$$$$
					.*</\>				# $$$$thematchingendtag$$$$
					[ \]*				# $$$$trailingspacestabs$$$$
					(?=\+|\)	# $$$$followedby$$$$  $$$$newlineorendofdocument$$$$
				)
			}{
				$$$$my$$$$ $$$$$key$$$$ = $$$$md5_hex$$$$($);
				$$$$$g_html_blocks$$$${$$$$$key$$$$} = $;
				"\" . $$$$$key$$$$ . "\";
			}$$$$egmx$$$$;
	# $$$$Specialcasejustfor$$$$ <$$$$hr$$$$ />. $$$$Itwaseasiertomake$$$$  $$$$specialcasethan$$$$
	# $$$$tomaketheotherregexmorecomplicated$$$$.	
	$$$$$text$$$$ =~ {
				(?:
					(?<=\)		# $$$$Startingafter$$$$  $$$$blankline$$$$
					|				# $$$$or$$$$
					\?			# $$$$thebeginningofthedoc$$$$
				)
				(						# $$$$savein$$$$ $
					[ ]{,$$$$$less_than_tab$$$$}
					<($$$$hr$$$$)				# $$$$starttag$$$$ = $
					\					# $$$$wordbreak$$$$
					([^<>])*?			# 
					/?>					# $$$$thematchingendtag$$$$
					[ \]*
					(?=\,}|\)		# $$$$followedby$$$$  $$$$blanklineorendofdocument$$$$
				)
			}{
				$$$$my$$$$ $$$$$key$$$$ = $$$$md5_hex$$$$($);
				$$$$$g_html_blocks$$$${$$$$$key$$$$} = $;
				"\" . $$$$$key$$$$ . "\";
			}$$$$egx$$$$;

	# $$$$SpecialcaseforstandaloneHTMLcomments$$$$:
	$$$$$text$$$$ =~ {
				(?:
					(?<=\)		# $$$$Startingafter$$$$  $$$$blankline$$$$
					|				# $$$$or$$$$
					\?			# $$$$thebeginningofthedoc$$$$
				)
				(						# $$$$savein$$$$ $
					[ ]{,$$$$$less_than_tab$$$$}
					(?:
						<!
						(--.*?--\*)+
						>
					)
					[ \]*
					(?=\,}|\)		# $$$$followedby$$$$  $$$$blanklineorendofdocument$$$$
				)
			}{
				$$$$my$$$$ $$$$$key$$$$ = $$$$md5_hex$$$$($);
				$$$$$g_html_blocks$$$${$$$$$key$$$$} = $;
				"\" . $$$$$key$$$$ . "\";
			}$$$$egx$$$$;


	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_RunBlockGamut$$$$ {
#
# $$$$Theseareallthetransformationsthatformblocklevel$$$$
# $$$$tagslikeparagraphs$$$$, $$$$headers$$$$, $$$$andlistitems$$$$.
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$$text$$$$ = $$$$_DoHeaders$$$$($$$$$text$$$$);

	# $$$$DoHorizontalRules$$$$:
	$$$$$text$$$$ =~ {^[ ]{}([ ]?\*[ ]?){,}[ \]*$}{\$$$$hrg_empty_element_suffixgmx$$$$;
	$$$$$text$$$$ =~ {^[ ]{}([ ]? -[ ]?){,}[ \]*$}{\$$$$hrg_empty_element_suffixgmx$$$$;
	$$$$$text$$$$ =~ {^[ ]{}([ ]? [ ]?){,}[ \]*$}{\$$$$hrg_empty_element_suffixgmx$$$$;

	$$$$$text$$$$ = $$$$_DoLists$$$$($$$$$text$$$$);

	$$$$$text$$$$ = $$$$_DoCodeBlocks$$$$($$$$$text$$$$);

	$$$$$text$$$$ = $$$$_DoBlockQuotes$$$$($$$$$text$$$$);

	# $$$$Wealreadyran_HashHTMLBlocks$$$$() $$$$before$$$$, $$$$inMarkdown$$$$(), $$$$butthat$$$$
	# $$$$wastoescaperawHTMLintheoriginalMarkdownsource$$$$. $$$$Thistime$$$$,
	# $$$$wereescapingthemarkupwevejustcreated$$$$, $$$$sothatwedonwrap$$$$
	# <> $$$$tagsaroundblockleveltags$$$$.
	$$$$$text$$$$ = $$$$_HashHTMLBlocks$$$$($$$$$text$$$$);

	$$$$$text$$$$ = $$$$_FormParagraphs$$$$($$$$$text$$$$);

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_RunSpanGamut$$$$ {
#
# $$$$Theseareallthetransformationsthatoccur$$$$ *$$$$within$$$$* $$$$blocklevel$$$$
# $$$$tagslikeparagraphs$$$$, $$$$headers$$$$, $$$$andlistitems$$$$.
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$$text$$$$ = $$$$_DoCodeSpans$$$$($$$$$text$$$$);

	$$$$$text$$$$ = $$$$_EscapeSpecialChars$$$$($$$$$text$$$$);

	# $$$$Processanchorandimagetags$$$$. $$$$Imagesmustcomefirst$$$$,
	# $$$$because$$$$ ![$$$$foo$$$$][] $$$$lookslikeananchor$$$$.
	$$$$$text$$$$ = $$$$_DoImages$$$$($$$$$text$$$$);
	$$$$$text$$$$ = $$$$_DoAnchors$$$$($$$$$text$$$$);

	# $$$$Makelinksoutofthingslike$$$$ `<$$$$http$$$$://$$$$examplecom$$$$/>`
	# $$$$Mustcomeafter_DoAnchors$$$$(), $$$$becauseyoucanuse$$$$ < $$$$and$$$$ >
	# $$$$delimitersininlinelinkslike$$$$ [$$$$this$$$$](<$$$$url$$$$>).
	$$$$$text$$$$ = $$$$_DoAutoLinks$$$$($$$$$text$$$$);

	$$$$$text$$$$ = $$$$_EncodeAmpsAndAngles$$$$($$$$$text$$$$);

	$$$$$text$$$$ = $$$$_DoItalicsAndBold$$$$($$$$$text$$$$);

	# $$$$Dohardbreaks$$$$:
	$$$$$text$$$$ =~ / {,}\/ <$$$$brg_empty_element_suffix$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_EscapeSpecialChars$$$$ {
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;
	$$$$my$$$$ $$$$$tokens$$$$ ||= $$$$_TokenizeHTML$$$$($$$$$text$$$$);

	$$$$$text$$$$ = '';   # $$$$rebuild$$$$ $$$$$textfromthetokens$$$$
# 	$$$$my$$$$ $$$$$in_pre$$$$ = ;	 # $$$$Keeptrackofwhenwereinside$$$$ <$$$$pre$$$$> $$$$or$$$$ <$$$$code$$$$> $$$$tags$$$$.
# 	$$$$my$$$$ $$$$$tags_to_skip$$$$ = $$$$qr$$$$!<(/?)(?:$$$$precodekbdscriptmath$$$$)[\>]!;

	$$$$foreachmy$$$$ $$$$$cur_token$$$$ (@$$$$$tokens$$$$) {
		$$$$if$$$$ ($$$$$cur_token$$$$->[] $$$$eq$$$$ "$$$$tag$$$$") {
			# $$$$Withintags$$$$, $$$$encode$$$$ * $$$$andsotheydonconflict$$$$
			# $$$$withtheiruseinMarkdownforitalicsandstrong$$$$.
			# $$$$Werereplacingeachsuchcharacterwithits$$$$
			# $$$$correspondingMD5checksumvalue$$$$; $$$$thisislikely$$$$
			# $$$$overkill$$$$, $$$$butitshouldpreventusfromcolliding$$$$
			# $$$$withtheescapevaluesbyaccident$$$$.
			$$$$$cur_token$$$$->[] =~  ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;
			$$$$$cur_token$$$$->[] =~  $$$$s_$$$$  !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;
			$$$$$text$$$$ .= $$$$$cur_token$$$$->[];
		} $$$$else$$$$ {
			$$$$my$$$$ $ = $$$$$cur_token$$$$->[];
			$ = $$$$_EncodeBackslashEscapes$$$$($);
			$$$$$text$$$$ .= $;
		}
	}
	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_DoAnchors$$$$ {
#
# $$$$TurnMarkdownlinkshortcutsintoXHTML$$$$ <> $$$$tags$$$$.
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	#
	# $$$$First$$$$, $$$$handlereferencestylelinks$$$$: [$$$$linktext$$$$] [$$$$id$$$$]
	#
	$$$$$text$$$$ =~ {
		(					# $$$$wrapwholematchin$$$$ $
		  \[
		    ($$$$$g_nested_brackets$$$$)	# $$$$linktext$$$$ = $
		  \]

		  [ ]?				# $$$$oneoptionalspace$$$$
		  (?:\[ ]*)?		# $$$$oneoptionalnewlinefollowedbyspaces$$$$

		  \[
		    (.*?)		# $$$$id$$$$ = $
		  \]
		)
	}{
		$$$$my$$$$ $$$$$result$$$$;
		$$$$my$$$$ $$$$$whole_match$$$$ = $;
		$$$$my$$$$ $$$$$link_text$$$$   = $;
		$$$$my$$$$ $$$$$link_id$$$$     = $$$$lc$$$$ $;

		$$$$if$$$$ ($$$$$link_ideq$$$$ "") {
			$$$$$link_id$$$$ = $$$$lc$$$$ $$$$$link_text$$$$;     # $$$$forshortcutlinkslike$$$$ [$$$$this$$$$][].
		}

		$$$$if$$$$ ($$$$defined$$$$ $$$$$g_urls$$$${$$$$$link_id$$$$}) {
			$$$$my$$$$ $$$$$url$$$$ = $$$$$g_urls$$$${$$$$$link_id$$$$};
			$$$$$url$$$$ =~ ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;		# $$$$Wevegottoencodethesetoavoid$$$$
			$$$$$url$$$$ =~ !   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;		# $$$$conflictingwithitalicsbold$$$$.
			$$$$$result$$$$ = "< $$$$href$$$$=\"$$$$$url$$$$\"";
			$$$$if$$$$ ( $$$$defined$$$$ $$$$$g_titles$$$${$$$$$link_id$$$$} ) {
				$$$$my$$$$ $$$$$title$$$$ = $$$$$g_titles$$$${$$$$$link_id$$$$};
				$$$$$title$$$$ =~ ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;
				$$$$$title$$$$ =~ !   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;
				$$$$$result$$$$ .=  " $$$$title$$$$=\"$$$$$title$$$$\"";
			}
			$$$$$result$$$$ .= ">$$$$$link_text$$$$</>";
		}
		$$$$else$$$$ {
			$$$$$result$$$$ = $$$$$whole_match$$$$;
		}
		$$$$$result$$$$;
	}$$$$xsge$$$$;

	#
	# $$$$Next$$$$, $$$$inlinestylelinks$$$$: [$$$$linktext$$$$]($$$$url$$$$ "$$$$optionaltitle$$$$")
	#
	$$$$$text$$$$ =~ {
		(				# $$$$wrapwholematchin$$$$ $
		  \[
		    ($$$$$g_nested_brackets$$$$)	# $$$$linktext$$$$ = $
		  \]
		  \(			# $$$$literalparen$$$$
		  	[ \]*
			<?(.*?)>?	# $$$$href$$$$ = $
		  	[ \]*
			(			# $
			  (['"])	# $$$$quotechar$$$$ = $
			  (.*?)		# $$$$Title$$$$ = $
			  \		# $$$$matchingquote$$$$
			)?			# $$$$titleisoptional$$$$
		  \)
		)
	}{
		$$$$my$$$$ $$$$$result$$$$;
		$$$$my$$$$ $$$$$whole_match$$$$ = $;
		$$$$my$$$$ $$$$$link_text$$$$   = $;
		$$$$my$$$$ $$$$$url$$$$	  		= $;
		$$$$my$$$$ $$$$$title$$$$		= $;

		$$$$$url$$$$ =~ ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;		# $$$$Wevegottoencodethesetoavoid$$$$
		$$$$$url$$$$ =~ !   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;		# $$$$conflictingwithitalicsbold$$$$.
		$$$$$result$$$$ = "< $$$$href$$$$=\"$$$$$url$$$$\"";

		$$$$if$$$$ ($$$$defined$$$$ $$$$$title$$$$) {
			$$$$$title$$$$ =~ /"/&$$$$quot$$$$;/;
			$$$$$title$$$$ =~ ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;
			$$$$$title$$$$ =~ !   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;
			$$$$$result$$$$ .=  " $$$$title$$$$=\"$$$$$title$$$$\"";
		}

		$$$$$result$$$$ .= ">$$$$$link_text$$$$</>";

		$$$$$result$$$$;
	}$$$$xsge$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_DoImages$$$$ {
#
# $$$$TurnMarkdownimageshortcutsinto$$$$ <$$$$img$$$$> $$$$tags$$$$.
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	#
	# $$$$First$$$$, $$$$handlereferencestylelabeledimages$$$$: ![$$$$alttext$$$$][$$$$id$$$$]
	#
	$$$$$text$$$$ =~ {
		(				# $$$$wrapwholematchin$$$$ $
		  !\[
		    (.*?)		# $$$$alttext$$$$ = $
		  \]

		  [ ]?				# $$$$oneoptionalspace$$$$
		  (?:\[ ]*)?		# $$$$oneoptionalnewlinefollowedbyspaces$$$$

		  \[
		    (.*?)		# $$$$id$$$$ = $
		  \]

		)
	}{
		$$$$my$$$$ $$$$$result$$$$;
		$$$$my$$$$ $$$$$whole_match$$$$ = $;
		$$$$my$$$$ $$$$$alt_text$$$$    = $;
		$$$$my$$$$ $$$$$link_id$$$$     = $$$$lc$$$$ $;

		$$$$if$$$$ ($$$$$link_ideq$$$$ "") {
			$$$$$link_id$$$$ = $$$$lc$$$$ $$$$$alt_text$$$$;     # $$$$forshortcutlinkslike$$$$ ![$$$$this$$$$][].
		}

		$$$$$alt_text$$$$ =~ /"/&$$$$quot$$$$;/;
		$$$$if$$$$ ($$$$defined$$$$ $$$$$g_urls$$$${$$$$$link_id$$$$}) {
			$$$$my$$$$ $$$$$url$$$$ = $$$$$g_urls$$$${$$$$$link_id$$$$};
			$$$$$url$$$$ =~ ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;		# $$$$Wevegottoencodethesetoavoid$$$$
			$$$$$url$$$$ =~ !   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;		# $$$$conflictingwithitalicsbold$$$$.
			$$$$$result$$$$ = "<$$$$imgsrc$$$$=\"$$$$$url$$$$\" $$$$alt$$$$=\"$$$$$alt_text$$$$\"";
			$$$$if$$$$ ($$$$defined$$$$ $$$$$g_titles$$$${$$$$$link_id$$$$}) {
				$$$$my$$$$ $$$$$title$$$$ = $$$$$g_titles$$$${$$$$$link_id$$$$};
				$$$$$title$$$$ =~ ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;
				$$$$$title$$$$ =~ !   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;
				$$$$$result$$$$ .=  " $$$$title$$$$=\"$$$$$title$$$$\"";
			}
			$$$$$result$$$$ .= $$$$$g_empty_element_suffix$$$$;
		}
		$$$$else$$$$ {
			# $$$$IftherenosuchlinkID$$$$, $$$$leaveintact$$$$:
			$$$$$result$$$$ = $$$$$whole_match$$$$;
		}

		$$$$$result$$$$;
	}$$$$xsge$$$$;

	#
	# $$$$Next$$$$, $$$$handleinlineimages$$$$:  ![$$$$alttext$$$$]($$$$url$$$$ "$$$$optionaltitle$$$$")
	# $$$$Donforget$$$$: $$$$encode$$$$ * $$$$and$$$$

	$$$$$text$$$$ =~ {
		(				# $$$$wrapwholematchin$$$$ $
		  !\[
		    (.*?)		# $$$$alttext$$$$ = $
		  \]
		  \(			# $$$$literalparen$$$$
		  	[ \]*
			<?(\+?)>?	# $$$$srcurl$$$$ = $
		  	[ \]*
			(			# $
			  (['"])	# $$$$quotechar$$$$ = $
			  (.*?)		# $$$$title$$$$ = $
			  \		# $$$$matchingquote$$$$
			  [ \]*
			)?			# $$$$titleisoptional$$$$
		  \)
		)
	}{
		$$$$my$$$$ $$$$$result$$$$;
		$$$$my$$$$ $$$$$whole_match$$$$ = $;
		$$$$my$$$$ $$$$$alt_text$$$$    = $;
		$$$$my$$$$ $$$$$url$$$$	  		= $;
		$$$$my$$$$ $$$$$title$$$$		= '';
		$$$$if$$$$ ($$$$defined$$$$($)) {
			$$$$$title$$$$		= $;
		}

		$$$$$alt_text$$$$ =~ /"/&$$$$quot$$$$;/;
		$$$$$title$$$$    =~ /"/&$$$$quot$$$$;/;
		$$$$$url$$$$ =~ ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;		# $$$$Wevegottoencodethesetoavoid$$$$
		$$$$$url$$$$ =~ !   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;		# $$$$conflictingwithitalicsbold$$$$.
		$$$$$result$$$$ = "<$$$$imgsrc$$$$=\"$$$$$url$$$$\" $$$$alt$$$$=\"$$$$$alt_text$$$$\"";
		$$$$if$$$$ ($$$$defined$$$$ $$$$$title$$$$) {
			$$$$$title$$$$ =~ ! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;
			$$$$$title$$$$ =~ !   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;
			$$$$$result$$$$ .=  " $$$$title$$$$=\"$$$$$title$$$$\"";
		}
		$$$$$result$$$$ .= $$$$$g_empty_element_suffix$$$$;

		$$$$$result$$$$;
	}$$$$xsge$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_DoHeaders$$$$ {
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	# $$$$Setextstyleheaders$$$$:
	#	  $$$$Header$$$$
	#	  ========
	#  
	#	  $$$$Header$$$$
	#	  --------
	#
	$$$$$text$$$$ =~ { ^(.+)[ \]*\=+[ \]*\+ }{
		"<$$$$h1$$$$>"  .  $$$$_RunSpanGamut$$$$($)  .  "</$$$$h1$$$$>\";
	}$$$$egmx$$$$;

	$$$$$text$$$$ =~ { ^(.+)[ \]*\-+[ \]*\+ }{
		"<$$$$h2$$$$>"  .  $$$$_RunSpanGamut$$$$($)  .  "</$$$$h2$$$$>\";
	}$$$$egmx$$$$;


	# $$$$atxstyleheaders$$$$:
	#	# $$$$Header$$$$
	#	## $$$$Header$$$$
	#	## $$$$Headerwithclosinghashes$$$$ ##
	#	...
	#	###### $$$$Header$$$$
	#
	$$$$$text$$$$ =~ {
			^(\#{})	# $ = $$$$stringof$$$$ #'
			[ \]*
			(.+?)		# $ = $$$$Headertext$$$$
			[ \]*
			\#*			# $$$$optionalclosing$$$$ #' ($$$$notcounted$$$$)
			\+
		}{
			$$$$my$$$$ $$$$$h_level$$$$ = $$$$length$$$$($);
			"<$$$$h_level$$$$>"  .  $$$$_RunSpanGamut$$$$($)  .  "</$$$$h_level$$$$>\";
		}$$$$egmx$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_DoLists$$$$ {
#
# $$$$FormHTMLordered$$$$ ($$$$numbered$$$$) $$$$andunordered$$$$ ($$$$bulleted$$$$) $$$$lists$$$$.
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;
	$$$$my$$$$ $$$$$less_than_tab$$$$ = $$$$$g_tab_width$$$$ - ;

	# $$$$Reusablepatternstomatchlistitembulletsandnumbermarkers$$$$:
	$$$$my$$$$ $$$$$marker_ul$$$$  = $$$$qr$$$$/[*+-]/;
	$$$$my$$$$ $$$$$marker_ol$$$$  = $$$$qr$$$$/\+[.]/;
	$$$$my$$$$ $$$$$marker_any$$$$ = $$$$qr$$$$/(?:$$$$$marker_ul$$$$|$$$$$marker_ol$$$$)/;

	# $$$$Reusablepatterntomatchanyentirelulorollist$$$$:
	$$$$my$$$$ $$$$$whole_list$$$$ = $$$$qr$$$${
		(								# $ = $$$$wholelist$$$$
		  (								# $
			[ ]{,$$$$$less_than_tab$$$$}
			(${$$$$marker_any$$$$})				# $ = $$$$firstlistitemmarker$$$$
			[ \]+
		  )
		  (?:.+?)
		  (								# $
			  \
			|
			  \,}
			  (?=\)
			  (?!						# $$$$Negativelookaheadforanotherlistitemmarker$$$$
				[ \]*
				${$$$$marker_any$$$$}[ \]+
			  )
		  )
		)
	}$$$$mx$$$$;

	# $$$$Weuse$$$$  $$$$differentprefixbeforenestedliststhantoplevellists$$$$.
	# $$$$Seeextendedcommentin_ProcessListItems$$$$().
	#
	# $$$$Note$$$$: $$$$There$$$$  $$$$bitofduplicationhere$$$$. $$$$Myoriginalimplementation$$$$
	# $$$$created$$$$  $$$$scalarregexpatternastheconditionalresultoftheteston$$$$
	# $$$$$g_list_level$$$$, $$$$andthenonlyranthe$$$$ $$$$$text$$$$ =~ {...}{...}$$$$egmx$$$$
	# $$$$substitutiononce$$$$, $$$$usingthescalarasthepattern$$$$. $$$$Thisworked$$$$,
	# $$$$everywhereexceptwhenrunningunderMTonmyhostingaccountatPair$$$$
	# $$$$Networks$$$$. $$$$There$$$$, $$$$thiscausedallrebuildstobekilledbythereaper$$$$ ($$$$or$$$$
	# $$$$perhapstheycrashed$$$$, $$$$butthatseemsincrediblyunlikelygiventhatthe$$$$
	# $$$$samescriptonthesameserverranfine$$$$ *$$$$except$$$$* $$$$underMT$$$$. $$$$vespent$$$$
	# $$$$moretimetryingtofigureoutwhythisishappeningthanliketo$$$$
	# $$$$admit$$$$. $$$$Myonlyguess$$$$, $$$$backedupbythefactthatthisworkaroundworks$$$$,
	# $$$$isthatPerloptimizesthesubstitionwhenitcanfigureoutthatthe$$$$
	# $$$$patternwillneverchange$$$$, $$$$andwhenthisoptimizationisnon$$$$, $$$$werun$$$$
	# $$$$afoulofthereaper$$$$. $$$$Thus$$$$, $$$$theslightlyredundantcodetothatusestwo$$$$
	# $$$$static$$$$/// $$$$patternsratherthanoneconditionalpattern$$$$.

	$$$$if$$$$ ($$$$$g_list_level$$$$) {
		$$$$$text$$$$ =~ {
				^
				$$$$$whole_list$$$$
			}{
				$$$$my$$$$ $$$$$list$$$$ = $;
				$$$$my$$$$ $$$$$list_type$$$$ = ($ =~ /$$$$$marker_ul$$$$/) ? "$$$$ul$$$$" : "$$$$ol$$$$";
				# $$$$Turndoublereturnsintotriplereturns$$$$, $$$$sothatwecanmake$$$$ 
				# $$$$paragraphforthelastitemin$$$$  $$$$list$$$$, $$$$ifnecessary$$$$:
				$$$$$list$$$$ =~ /\,}/\;
				$$$$my$$$$ $$$$$result$$$$ = $$$$_ProcessListItems$$$$($$$$$list$$$$, $$$$$marker_any$$$$);
				$$$$$result$$$$ = "<$$$$$list_type$$$$>\" . $$$$$result$$$$ . "</$$$$$list_type$$$$>\";
				$$$$$result$$$$;
			}$$$$egmx$$$$;
	}
	$$$$else$$$$ {
		$$$$$text$$$$ =~ {
				(?:(?<=\)|\?)
				$$$$$whole_list$$$$
			}{
				$$$$my$$$$ $$$$$list$$$$ = $;
				$$$$my$$$$ $$$$$list_type$$$$ = ($ =~ /$$$$$marker_ul$$$$/) ? "$$$$ul$$$$" : "$$$$ol$$$$";
				# $$$$Turndoublereturnsintotriplereturns$$$$, $$$$sothatwecanmake$$$$ 
				# $$$$paragraphforthelastitemin$$$$  $$$$list$$$$, $$$$ifnecessary$$$$:
				$$$$$list$$$$ =~ /\,}/\;
				$$$$my$$$$ $$$$$result$$$$ = $$$$_ProcessListItems$$$$($$$$$list$$$$, $$$$$marker_any$$$$);
				$$$$$result$$$$ = "<$$$$$list_type$$$$>\" . $$$$$result$$$$ . "</$$$$$list_type$$$$>\";
				$$$$$result$$$$;
			}$$$$egmx$$$$;
	}


	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_ProcessListItems$$$$ {
#
#	$$$$Processthecontentsof$$$$  $$$$singleorderedorunorderedlist$$$$, $$$$splittingit$$$$
#	$$$$intoindividuallistitems$$$$.
#

	$$$$my$$$$ $$$$$list_str$$$$ = $$$$shift$$$$;
	$$$$my$$$$ $$$$$marker_any$$$$ = $$$$shift$$$$;


	# $$$$The$$$$ $$$$$g_list_levelglobalkeepstrackofwhenwereinside$$$$  $$$$list$$$$.
	# $$$$Eachtimeweenter$$$$  $$$$list$$$$, $$$$weincrementit$$$$; $$$$whenweleave$$$$  $$$$list$$$$,
	# $$$$wedecrement$$$$. $$$$Ifitzero$$$$, $$$$werenotin$$$$  $$$$listanymore$$$$.
	#
	# $$$$Wedothisbecausewhenwerenotinside$$$$  $$$$list$$$$, $$$$wewanttotreat$$$$
	# $$$$somethinglikethis$$$$:
	#
	#		$$$$recommendupgradingtoversion$$$$
	#		. $$$$Oops$$$$, $$$$nowthislineistreated$$$$
	#		$$$$as$$$$  $$$$sublist$$$$.
	#
	# $$$$As$$$$  $$$$singleparagraph$$$$, $$$$despitethefactthatthesecondlinestarts$$$$
	# $$$$with$$$$  $$$$digitperiodspacesequence$$$$.
	#
	# $$$$Whereaswhenwereinside$$$$  $$$$list$$$$ ($$$$orsublist$$$$), $$$$thatlinewillbe$$$$
	# $$$$treatedasthestartof$$$$  $$$$sublist$$$$. $$$$What$$$$  $$$$kludge$$$$, $$$$huh$$$$? $$$$Thisis$$$$
	# $$$$anaspectofMarkdownsyntaxthathardtoparseperfectly$$$$
	# $$$$withoutresortingtomindreading$$$$. $$$$Perhapsthesolutionisto$$$$
	# $$$$changethesyntaxrulessuchthatsublistsmuststartwith$$$$ 
	# $$$$startingcardinalnumber$$$$; . "." $$$$or$$$$ ".".

	$$$$$g_list_level$$$$++;

	# $$$$trimtrailingblanklines$$$$:
	$$$$$list_str$$$$ =~ /\,}\/\/;


	$$$$$list_str$$$$ =~ {
		(\)?							# $$$$leadingline$$$$ = $
		(^[ \]*)						# $$$$leadingwhitespace$$$$ = $
		($$$$$marker_any$$$$) [ \]+			# $$$$listmarker$$$$ = $
		((?:.+?)						# $$$$listitemtext$$$$   = $
		(\}))
		(?= \* (\ | \ ($$$$$marker_any$$$$) [ \]+))
	}{
		$$$$my$$$$ $$$$$item$$$$ = $;
		$$$$my$$$$ $$$$$leading_line$$$$ = $;
		$$$$my$$$$ $$$$$leading_space$$$$ = $;

		$$$$if$$$$ ($$$$$leading_lineor$$$$ ($$$$$item$$$$ =~ /\,}/)) {
			$$$$$item$$$$ = $$$$_RunBlockGamut_Outdent$$$$($$$$$item$$$$));
		}
		$$$$else$$$$ {
			# $$$$Recursionforsublists$$$$:
			$$$$$item$$$$ = $$$$_DoLists_Outdent$$$$($$$$$item$$$$));
			$$$$chomp$$$$ $$$$$item$$$$;
			$$$$$item$$$$ = $$$$_RunSpanGamut$$$$($$$$$item$$$$);
		}

		"<$$$$li$$$$>" . $$$$$item$$$$ . "</$$$$li$$$$>\";
	}$$$$egmx$$$$;

	$$$$$g_list_level$$$$--;
	$$$$return$$$$ $$$$$list_str$$$$;
}



$$$$sub_DoCodeBlocks$$$$ {
#
#	$$$$ProcessMarkdown$$$$ `<$$$$pre$$$$><$$$$code$$$$>` $$$$blocks$$$$.
#	

	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$$text$$$$ =~ {
			(?:\|\)
			(	            # $ = $$$$thecodeblock$$$$ -- $$$$oneormorelines$$$$, $$$$startingwith$$$$  $$$$spacetab$$$$
			  (?:
			    (?:[ ]{$$$$$g_tab_width$$$$} | \)  # $$$$Linesmuststartwith$$$$  $$$$tabor$$$$  $$$$tabwidthofspaces$$$$
			    .*\+
			  )+
			)
			((?=^[ ]{,$$$$$g_tab_width$$$$}\)|\)	# $$$$Lookaheadfornonspaceatlinestart$$$$, $$$$orendofdoc$$$$
		}{
			$$$$my$$$$ $$$$$codeblock$$$$ = $;
			$$$$my$$$$ $$$$$result$$$$; # $$$$returnvalue$$$$

			$$$$$codeblock$$$$ = $$$$_EncodeCode_Outdent$$$$($$$$$codeblock$$$$));
			$$$$$codeblock$$$$ = $$$$_Detab$$$$($$$$$codeblock$$$$);
			$$$$$codeblock$$$$ =~ /\+//; # $$$$trimleadingnewlines$$$$
			$$$$$codeblock$$$$ =~ /\+\//; # $$$$trimtrailingwhitespace$$$$

			$$$$$result$$$$ = "\$$$$pre$$$$><$$$$code$$$$>" . $$$$$codeblock$$$$ . "\</$$$$code$$$$></$$$$pre$$$$>\";

			$$$$$result$$$$;
		}$$$$egmx$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_DoCodeSpans$$$$ {
#
# 	*	$$$$Backtickquotesareusedfor$$$$ <$$$$code$$$$></$$$$code$$$$> $$$$spans$$$$.
# 
# 	*	$$$$Youcanusemultiplebackticksasthedelimitersifyouwantto$$$$
# 		$$$$includeliteralbackticksinthecodespan$$$$. $$$$So$$$$, $$$$thisinput$$$$:
#     
#         $$$$Justtype$$$$ ``$$$$foo$$$$ `$$$$bar$$$$` $$$$baz$$$$`` $$$$attheprompt$$$$.
#     
#     	$$$$Willtranslateto$$$$:
#     
#         <$$$$Justtype$$$$ <$$$$codefoo$$$$ `$$$$bar$$$$` $$$$baz$$$$</$$$$code$$$$> $$$$attheprompt$$$$.</>
#     
#		$$$$Therenoarbitrarylimittothenumberofbackticksyou$$$$
#		$$$$canuseasdelimters$$$$. $$$$Ifyouneedthreeconsecutivebackticks$$$$
#		$$$$inyourcode$$$$, $$$$usefourfordelimiters$$$$, $$$$etc$$$$.
#
#	*	$$$$Youcanusespacestogetliteralbackticksattheedges$$$$:
#     
#         ... $$$$type$$$$ `` `$$$$bar$$$$` `` ...
#     
#     	$$$$Turnsto$$$$:
#     
#         ... $$$$type$$$$ <$$$$code$$$$>`$$$$bar$$$$`</$$$$code$$$$> ...
#

	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$$text$$$$ =~ @
			(`+)		# $ = $$$$Openingrunof$$$$ `
			(.+?)		# $ = $$$$Thecodeblock$$$$
			(?<!`)
			\			# $$$$Matchingcloser$$$$
			(?!`)
		@
 			$$$$my$$$$ $ = "$";
 			$ =~ /^[ \]*//; # $$$$leadingwhitespace$$$$
 			$ =~ /[ \]*$//; # $$$$trailingwhitespace$$$$
 			$ = $$$$_EncodeCode$$$$($);
			"<$$$$code$$$$>$</$$$$code$$$$>";
		@$$$$egsx$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_EncodeCode$$$$ {
#
# $$$$EncodeescapecertaincharactersinsideMarkdowncoderuns$$$$.
# $$$$Thepointisthatincode$$$$, $$$$thesecharactersareliterals$$$$,
# $$$$andlosetheirspecialMarkdownmeanings$$$$.
#
    $$$$local$$$$ $ = $$$$shift$$$$;

	# $$$$Encodeallampersands$$$$; $$$$HTMLentitiesarenot$$$$
	# $$$$entitieswithin$$$$  $$$$Markdowncodespan$$$$.
	/&/&$$$$amp$$$$;/;

	# $$$$Encode$$$$ $', $$$$butonlyifwererunningunderBlosxom$$$$.
	# ($$$$BlosxominterpolatesPerlvariablesinarticlebodies$$$$.)
	{
		$$$$nowarnings$$$$ '$$$$once$$$$';
    	$$$$if$$$$ ($$$$defined$$$$($$$$$blosxom$$$$::$$$$version$$$$)) {
    		/\$/&#$$$$$$$$;/;	
    	}
    }


	# $$$$Dotheanglebracketsonganddance$$$$:
	! <  !&$$$$lt$$$$;!$$$$gx$$$$;
	! >  !&$$$$gt$$$$;!$$$$gx$$$$;

	# $$$$Now$$$$, $$$$escapecharactersthataremagicinMarkdown$$$$:
	! \* !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;
	$$$$s_$$$$  !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;
	! {  !$$$$$g_escape_table$$$${'{'}!$$$$gx$$$$;
	! }  !$$$$$g_escape_table$$$${'}'}!$$$$gx$$$$;
	! \[ !$$$$$g_escape_table$$$${'['}!$$$$gx$$$$;
	! \] !$$$$$g_escape_table$$$${']'}!$$$$gx$$$$;
	! \\ !$$$$$g_escape_table$$$${'\\'}!$$$$gx$$$$;

	$$$$return$$$$ $;
}


$$$$sub_DoItalicsAndBold$$$$ {
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	# <$$$$strong$$$$> $$$$mustgofirst$$$$:
	$$$$$text$$$$ =~ { (\*\*|$$$$__$$$$) (?=\) (.+?[*]*) (?<=\) \ }
		{<$$$$strong$$$$>$</$$$$strong$$$$>}$$$$gsx$$$$;

	$$$$$text$$$$ =~ { (\*|) (?=\) (.+?) (?<=\) \ }
		{<$$$$em$$$$>$</$$$$em$$$$>}$$$$gsx$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_DoBlockQuotes$$$$ {
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$$text$$$$ =~ {
		  (								# $$$$Wrapwholematchin$$$$ $
			(
			  ^[ \]*>[ \]?			# '>' $$$$atthestartof$$$$  $$$$line$$$$
			    .+\					# $$$$restofthefirstline$$$$
			  (.+\)*					# $$$$subsequentconsecutivelines$$$$
			  \*						# $$$$blanks$$$$
			)+
		  )
		}{
			$$$$my$$$$ $$$$$$$$$$ = $;
			$$$$$$$$$$ =~ /^[ \]*>[ \]?//$$$$gm$$$$;	# $$$$trimonelevelofquoting$$$$
			$$$$$$$$$$ =~ /^[ \]+$//$$$$mg$$$$;			# $$$$trimwhitespaceonlylines$$$$
			$$$$$$$$$$ = $$$$_RunBlockGamut$$$$($$$$$$$$$$);		# $$$$recurse$$$$

			$$$$$$$$$$ =~ /^/  /;
			# $$$$Theseleadingspacesscrewwith$$$$ <$$$$pre$$$$> $$$$content$$$$, $$$$soweneedtofixthat$$$$:
			$$$$$$$$$$ =~ {
					(\*<$$$$pre$$$$>.+?</$$$$pre$$$$>)
				}{
					$$$$my$$$$ $$$$$pre$$$$ = $;
					$$$$$pre$$$$ =~ /^  //$$$$mg$$$$;
					$$$$$pre$$$$;
				}$$$$egsx$$$$;

			"<$$$$blockquote$$$$>\$$$$$$$$$</$$$$blockquote$$$$>\";
		}$$$$egmx$$$$;


	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_FormParagraphs$$$$ {
#
#	$$$$Params$$$$:
#		$$$$$text$$$$ - $$$$stringtoprocesswithhtml$$$$ <> $$$$tags$$$$
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	# $$$$Stripleadingandtrailinglines$$$$:
	$$$$$text$$$$ =~ /\+//;
	$$$$$text$$$$ =~ /\+\//;

	$$$$my$$$$ @$$$$grafs$$$$ = $$$$split$$$$(/\,}/, $$$$$text$$$$);

	#
	# $$$$Wrap$$$$ <> $$$$tags$$$$.
	#
	$$$$foreach$$$$ (@$$$$grafs$$$$) {
		$$$$unless$$$$ ($$$$defined$$$$( $$$$$g_html_blocks$$$${$} )) {
			$ = $$$$_RunSpanGamut$$$$($);
			/^([ \]*)/<>/;
			$ .= "</>";
		}
	}

	#
	# $$$$UnhashifyHTMLblocks$$$$
	#
	$$$$foreach$$$$ (@$$$$grafs$$$$) {
		$$$$if$$$$ ($$$$defined$$$$( $$$$$g_html_blocks$$$${$} )) {
			$ = $$$$$g_html_blocks$$$${$};
		}
	}

	$$$$returnjoin$$$$ "\", @$$$$grafs$$$$;
}


$$$$sub_EncodeAmpsAndAngles$$$$ {
# $$$$Smartprocessingforampersandsandanglebracketsthatneedtobeencoded$$$$.

	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	# $$$$AmpersandencodingbasedentirelyonNatIronsAmputatorMTplugin$$$$:
	#   $$$$http$$$$://$$$$bumpponetprojectsamputator$$$$/
 	$$$$$text$$$$ =~ /&(?!#?[$$$$xX$$$$]?(?:[$$$$9afA$$$$]+|\+);)/&$$$$amp$$$$;/;

	# $$$$Encodenaked$$$$ <'
 	$$$$$text$$$$ =~ {<(?![-/?\$!])}{&$$$$lt$$$$;}$$$$gi$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_EncodeBackslashEscapes$$$$ {
#
#   $$$$Parameter$$$$:  $$$$String$$$$.
#   $$$$Returns$$$$:    $$$$Thestring$$$$, $$$$withafterprocessingthefollowingbackslash$$$$
#               $$$$escapesequences$$$$.
#
    $$$$local$$$$ $ = $$$$shift$$$$;

    ! \\\\  !$$$$$g_escape_table$$$${'\\'}!$$$$gx$$$$;		# $$$$Mustprocessescapedbackslashesfirst$$$$.
    ! \\`   !$$$$$g_escape_table$$$${'`'}!$$$$gx$$$$;
    ! \\\*  !$$$$$g_escape_table$$$${'*'}!$$$$gx$$$$;
    ! \\   !$$$$$g_escape_table$$$${''}!$$$$gx$$$$;
    ! \\\{  !$$$$$g_escape_table$$$${'{'}!$$$$gx$$$$;
    ! \\\}  !$$$$$g_escape_table$$$${'}'}!$$$$gx$$$$;
    ! \\\[  !$$$$$g_escape_table$$$${'['}!$$$$gx$$$$;
    ! \\\]  !$$$$$g_escape_table$$$${']'}!$$$$gx$$$$;
    ! \\\(  !$$$$$g_escape_table$$$${'('}!$$$$gx$$$$;
    ! \\\)  !$$$$$g_escape_table$$$${')'}!$$$$gx$$$$;
    ! \\>   !$$$$$g_escape_table$$$${'>'}!$$$$gx$$$$;
    ! \\\#  !$$$$$g_escape_table$$$${'#'}!$$$$gx$$$$;
    ! \\\+  !$$$$$g_escape_table$$$${'+'}!$$$$gx$$$$;
    ! \\\-  !$$$$$g_escape_table$$$${'-'}!$$$$gx$$$$;
    ! \\\.  !$$$$$g_escape_table$$$${'.'}!$$$$gx$$$$;
    { \\!  }{$$$$$g_escape_table$$$${'!'}}$$$$gx$$$$;

    $$$$return$$$$ $;
}


$$$$sub_DoAutoLinks$$$$ {
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$$text$$$$ =~ {<(($$$$https$$$$?|$$$$ftp$$$$):[^'">\]+)>}{< $$$$href$$$$="$">$</>}$$$$gi$$$$;

	# $$$$Emailaddresses$$$$: <$$$$addressdomainfoo$$$$>
	$$$$$text$$$$ =~ {
		<
        (?:$$$$mailto$$$$:)?
		(
			[-.\]+
			\@
			[--$$$$z0$$$$]+(\.[--$$$$z0$$$$]+)*\.[-]+
		)
		>
	}{
		$$$$_EncodeEmailAddress$$$$( $$$$_UnescapeSpecialChars$$$$($) );
	}$$$$egix$$$$;

	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_EncodeEmailAddress$$$$ {
#
#	$$$$Input$$$$: $$$$anemailaddress$$$$, . "$$$$fooexamplecom$$$$"
#
#	$$$$Output$$$$: $$$$theemailaddressas$$$$  $$$$mailtolink$$$$, $$$$witheachcharacter$$$$
#		$$$$oftheaddressencodedaseither$$$$  $$$$decimalorhexentity$$$$, $$$$in$$$$
#		$$$$thehopesoffoilingmostaddressharvestingspambots$$$$. .:
#
#	  < $$$$href$$$$="&#$$$$x6D$$$$;&#$$$$97$$$$;&#$$$$$$$$;&#$$$$$$$$;&#$$$$x74$$$$;&#$$$$$$$$;:&#$$$$$$$$;&#$$$$$$$$;&#$$$$$$$$;&#$$$$64$$$$;&#$$$$$$$$;
#       &#$$$$x61$$$$;&#$$$$$$$$;&#$$$$x70$$$$;&#$$$$$$$$;&#$$$$x65$$$$;&#$$$$x2E$$$$;&#$$$$99$$$$;&#$$$$$$$$;&#$$$$$$$$;">&#$$$$$$$$;&#$$$$$$$$;&#$$$$$$$$;
#       &#$$$$64$$$$;&#$$$$$$$$&#$$$$x61$$$$;&#$$$$$$$$;&#$$$$x70$$$$;&#$$$$$$$$;&#$$$$x65$$$$;&#$$$$x2E$$$$;&#$$$$99$$$$;&#$$$$$$$$;&#$$$$$$$$;</>
#
#	$$$$Basedon$$$$  $$$$filterbyMatthewWickline$$$$, $$$$postedtotheBBEditTalk$$$$
#	$$$$mailinglist$$$$: <$$$$http$$$$://$$$$tinyurlcomyu7ue$$$$>
#

	$$$$my$$$$ $$$$$addr$$$$ = $$$$shift$$$$;

	$$$$srand$$$$;
	$$$$my$$$$ @$$$$encode$$$$ = (
		$$$$sub$$$$ { '&#' .                 $$$$ordshift$$$$)   . ';' },
		$$$$sub$$$$ { '&#' . $$$$sprintf$$$$( "%", $$$$ordshift$$$$) ) . ';' },
		$$$$sub$$$$ {                            $$$$shift$$$$          },
	);

	$$$$$addr$$$$ = "$$$$mailto$$$$:" . $$$$$addr$$$$;

	$$$$$addr$$$$ =~ {(.)}{
		$$$$my$$$$ $$$$$char$$$$ = $;
		$$$$if$$$$ ( $$$$$chareq$$$$ '@' ) {
			# $$$$this$$$$ *$$$$must$$$$* $$$$beencoded$$$$. $$$$insist$$$$.
			$$$$$char$$$$ = $$$$$encodeintrand$$$$]->($$$$$char$$$$);
		} $$$$elsif$$$$ ( $$$$$charne$$$$ ':' ) {
			# $$$$leave$$$$ ':' $$$$alone$$$$ ($$$$tospotmailto$$$$: $$$$later$$$$)
			$$$$my$$$$ $ = $$$$rand$$$$;
			# $$$$roughly10$$$$% $$$$raw$$$$, $$$$45$$$$% $$$$hex$$$$, $$$$45$$$$% $$$$dec$$$$
			$$$$$char$$$$ = (
				$ > .   ?  $$$$$encode$$$$]->($$$$$char$$$$)  :
				$ < .$$$$45$$$$  ?  $$$$$encode$$$$]->($$$$$char$$$$)  :
							 $$$$$encode$$$$]->($$$$$char$$$$)
			);
		}
		$$$$$char$$$$;
	}$$$$gex$$$$;

	$$$$$addr$$$$ = $$$$qq$$$${< $$$$href$$$$="$$$$$addr$$$$">$$$$$addr$$$$</>};
	$$$$$addr$$$$ =~ {">.+?:}{">}; # $$$$stripthemailto$$$$: $$$$fromthevisiblepart$$$$

	$$$$return$$$$ $$$$$addr$$$$;
}


$$$$sub_UnescapeSpecialChars$$$$ {
#
# $$$$Swapbackinallthespecialcharacterswevehidden$$$$.
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$while$$$$( $$$$my$$$$($$$$$char$$$$, $$$$$hash$$$$) = $$$$each$$$$(%$$$$g_escape_table$$$$) ) {
		$$$$$text$$$$ =~ /$$$$$hash$$$$/$$$$$char$$$$;
	}
    $$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_TokenizeHTML$$$$ {
#
#   $$$$Parameter$$$$:  $$$$StringcontainingHTMLmarkup$$$$.
#   $$$$Returns$$$$:    $$$$Referencetoanarrayofthetokenscomprisingtheinput$$$$
#               $$$$string$$$$. $$$$Eachtokeniseither$$$$  $$$$tag$$$$ ($$$$possiblywithnested$$$$,
#               $$$$tagscontainedtherein$$$$, $$$$suchas$$$$ < $$$$href$$$$="<$$$$MTFoo$$$$>">, $$$$or$$$$ 
#               $$$$runoftextbetweentags$$$$. $$$$Eachelementofthearrayis$$$$ 
#               $$$$twoelementarray$$$$; $$$$thefirstiseither$$$$ '$$$$tag$$$$' $$$$or$$$$ '$$$$text$$$$';
#               $$$$thesecondistheactualvalue$$$$.
#
#
#   $$$$Derivedfromthe_tokenize$$$$() $$$$subroutinefromBradChoateMTRegexplugin$$$$.
#       <$$$$http$$$$://$$$$wwwbradchoatecompastmtregexphp$$$$>
#

    $$$$my$$$$ $$$$$str$$$$ = $$$$shift$$$$;
    $$$$my$$$$ $$$$$pos$$$$ = ;
    $$$$my$$$$ $$$$$len$$$$ = $$$$length$$$$ $$$$$str$$$$;
    $$$$my$$$$ @$$$$tokens$$$$;

    $$$$my$$$$ $$$$$depth$$$$ = ;
    $$$$my$$$$ $$$$$nested_tags$$$$ = $$$$join$$$$('|', ('(?:<[-/!$](?:[^<>]')  $$$$$depth$$$$) . (')*>)'   $$$$$depth$$$$);
    $$$$my$$$$ $$$$$match$$$$ = $$$$qr$$$$/(?: <! ( -- .*? -- \* )+ > ) |  # $$$$comment$$$$
                   (?: <\? .*? \?> ) |              # $$$$processinginstruction$$$$
                   $$$$$nested_tagsix$$$$;                   # $$$$nestedtags$$$$

    $$$$while$$$$ ($$$$$str$$$$ =~ /($$$$$match$$$$)/) {
        $$$$my$$$$ $$$$$whole_tag$$$$ = $;
        $$$$my$$$$ $$$$$sec_start$$$$ = $$$$pos$$$$ $$$$$str$$$$;
        $$$$my$$$$ $$$$$tag_start$$$$ = $$$$$sec_start$$$$ - $$$$length$$$$ $$$$$whole_tag$$$$;
        $$$$if$$$$ ($$$$$pos$$$$ < $$$$$tag_start$$$$) {
            $$$$push$$$$ @$$$$tokens$$$$, ['$$$$text$$$$', $$$$substr$$$$($$$$$str$$$$, $$$$$pos$$$$, $$$$$tag_start$$$$ - $$$$$pos$$$$)];
        }
        $$$$push$$$$ @$$$$tokens$$$$, ['$$$$tag$$$$', $$$$$whole_tag$$$$];
        $$$$$pos$$$$ = $$$$pos$$$$ $$$$$str$$$$;
    }
    $$$$push$$$$ @$$$$tokens$$$$, ['$$$$text$$$$', $$$$substr$$$$($$$$$str$$$$, $$$$$pos$$$$, $$$$$len$$$$ - $$$$$pos$$$$)] $$$$if$$$$ $$$$$pos$$$$ < $$$$$len$$$$;
    \@$$$$tokens$$$$;
}


$$$$sub_Outdent$$$$ {
#
# $$$$Removeoneleveloflineleadingtabsorspaces$$$$
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$$text$$$$ =~ /^(\|[ ]{,$$$$$g_tab_width$$$$})//$$$$gm$$$$;
	$$$$return$$$$ $$$$$text$$$$;
}


$$$$sub_Detab$$$$ {
#
# $$$$Cribbedfrom$$$$  $$$$postbyBartLateur$$$$:
# <$$$$http$$$$://$$$$wwwnntpperlorggroupperlmacperlanyperl154$$$$>
#
	$$$$my$$$$ $$$$$text$$$$ = $$$$shift$$$$;

	$$$$$text$$$$ =~ {(.*?)\}{$.(' '  ($$$$$g_tab_width$$$$ - $$$$length$$$$($) % $$$$$g_tab_width$$$$))}$$$$ge$$$$;
	$$$$return$$$$ $$$$$text$$$$;
}


;

$$$$__END__$$$$


=$$$$pod$$$$

=$$$$head1NAME$$$$

$$$$Markdown$$$$>


=$$$$head1SYNOPSIS$$$$

$$$$Markdownpl$$$$> [ <--$$$$html4tags$$$$> ] [ <--$$$$version$$$$> ] [ <-$$$$shortversion$$$$> ]
    [ $$$$file$$$$> ... ]


=$$$$head1DESCRIPTION$$$$

$$$$Markdownis$$$$  $$$$texttoHTMLfilter$$$$; $$$$ittranslatesaneasytoread$$$$ /
$$$$easytowritestructuredtextformatintoHTML$$$$. $$$$Markdowntextformatismostsimilartothatofplaintextemail$$$$, $$$$andsupportsfeaturessuchasheaders$$$$, *$$$$emphasis$$$$*, $$$$codeblocks$$$$, $$$$blockquotes$$$$, $$$$andlinks$$$$.

$$$$Markdownsyntaxisdesignednotas$$$$  $$$$genericmarkuplanguage$$$$, $$$$butspecificallytoserveas$$$$  $$$$frontendto$$$$ ($$$$HTML$$$$. $$$$Youcan$$$$  $$$$usespanlevelHTMLtagsanywherein$$$$  $$$$Markdowndocument$$$$, $$$$andyoucanuseblocklevelHTMLtags$$$$ ($$$$like$$$$ <$$$$div$$$$> $$$$and$$$$ <$$$$table$$$$> $$$$aswell$$$$).

$$$$FormoreinformationaboutMarkdownsyntax$$$$, $$$$see$$$$:

    $$$$http$$$$://$$$$daringfireballnetprojectsmarkdown$$$$/


=$$$$head1OPTIONS$$$$

$$$$Use$$$$ "--" $$$$toendswitchparsing$$$$. $$$$Forexample$$$$, $$$$toopen$$$$  $$$$filenamed$$$$ "-", $$$$use$$$$:

	$$$$Markdownpl$$$$ -- -

=$$$$over$$$$


=$$$$item$$$$<--$$$$html4tags$$$$>

$$$$UseHTMLstyleforemptyelementtags$$$$, .:

    <$$$$$$$$$>

$$$$insteadofMarkdowndefaultXHTMLstyletags$$$$, .:

    <$$$$$$$$$ />


=$$$$item$$$$<->, <--$$$$version$$$$>

$$$$DisplayMarkdownversionnumberandcopyrightinformation$$$$.


=$$$$item$$$$<->, <--$$$$shortversion$$$$>

$$$$Displaytheshortformversionnumber$$$$.


=$$$$back$$$$



=$$$$head1BUGS$$$$

$$$$Tofilebugreportsorfeaturerequests$$$$ ($$$$otherthantopicslistedintheCaveatssectionabove$$$$) $$$$pleasesendemailto$$$$:

    $$$$supportdaringfireballnet$$$$

$$$$Pleaseincludewithyourreport$$$$: () $$$$theexampleinput$$$$; () $$$$theoutputyouexpected$$$$; () $$$$theoutputMarkdownactuallyproduced$$$$.


=$$$$head1VERSIONHISTORY$$$$

$$$$Seethereadmefilefordetailedreleasenotesforthisversion$$$$.

 - $$$$14Dec2004$$$$

 - $$$$28Aug2004$$$$


=$$$$head1AUTHOR$$$$

    $$$$JohnGruber$$$$
    $$$$http$$$$://$$$$daringfireballnet$$$$

    $$$$PHPportandothercontributionsbyMichelFortin$$$$
    $$$$http$$$$://$$$$michelfcom$$$$


=$$$$head1COPYRIGHTANDLICENSE$$$$

$$$$Copyright$$$$ () $$$$$$$$   
<$$$$http$$$$://$$$$daringfireballnet$$$$/>   
$$$$Allrightsreserved$$$$.

$$$$Redistributionanduseinsourceandbinaryforms$$$$, $$$$withorwithoutmodification$$$$, $$$$arepermittedprovidedthatthefollowingconditionsaremet$$$$:

* $$$$Redistributionsofsourcecodemustretaintheabovecopyrightnotice$$$$,
  $$$$thislistofconditionsandthefollowingdisclaimer$$$$.

* $$$$Redistributionsinbinaryformmustreproducetheabovecopyright$$$$
  $$$$notice$$$$, $$$$thislistofconditionsandthefollowingdisclaimerinthe$$$$
  $$$$documentationandorothermaterialsprovidedwiththedistribution$$$$.

* $$$$Neitherthename$$$$ "$$$$Markdown$$$$" $$$$northenamesofitscontributorsmay$$$$
  $$$$beusedtoendorseorpromoteproductsderivedfromthissoftware$$$$
  $$$$beusedtoendorseorpromoteproductsderivedfromthissoftware$$$$
  $$$$withoutspecificpriorwrittenpermission$$$$.

$$$$Thissoftwareisprovidedbythecopyrightholdersandcontributors$$$$ "$$$$asis$$$$" $$$$andanyexpressorimpliedwarranties$$$$, $$$$including$$$$, $$$$butnotlimitedto$$$$, $$$$theimpliedwarrantiesofmerchantabilityandfitnessfor$$$$ 
$$$$particularpurposearedisclaimed$$$$. $$$$Innoeventshallthecopyrightownerorcontributorsbeliableforanydirect$$$$, $$$$indirect$$$$, $$$$incidental$$$$, $$$$special$$$$,
$$$$exemplary$$$$, $$$$orconsequentialdamages$$$$ ($$$$including$$$$, $$$$butnotlimitedto$$$$,
$$$$procurementofsubstitutegoodsorservices$$$$; $$$$lossofuse$$$$, $$$$data$$$$, $$$$orprofits$$$$; $$$$orbusinessinterruption$$$$) $$$$howevercausedandonanytheoryofliability$$$$, $$$$whetherincontract$$$$, $$$$strictliability$$$$, $$$$ortort$$$$ ($$$$includingnegligenceorotherwise$$$$) $$$$arisinginanywayoutoftheuseofthissoftware$$$$, $$$$evenifadvisedofthepossibilityofsuchdamage$$$$.

=$$$$cut$$$$$$