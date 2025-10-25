# Tutorial steps for Battle - Deck Management Tutorial
# This script creates the tutorial steps for the full battle scene
extends Node

static func create_steps() -> Array[TutorialStep]:
	var steps: Array[TutorialStep] = []
	
	# Step 0: Welcome to Full Battle
	var step0 := TutorialStep.new()
	step0.narration_text = "Welcome to a real battle! Let's learn about deck management."
	step0.action_type = TutorialStep.ActionType.NONE
	step0.auto_advance_delay = 2.5
	step0.block_all_except_highlight = true
	steps.append(step0)
	
	# Step 1: Explain Draw Pile
	var step1 := TutorialStep.new()
	step1.narration_text = "This is your DRAW PILE. It shows how many cards are left to draw."
	step1.highlight_node_path = "BattleUI/DrawPileButton"
	step1.action_type = TutorialStep.ActionType.NONE
	step1.auto_advance_delay = 4.0
	step1.block_all_except_highlight = true
	steps.append(step1)
	
	# Step 3: Explain Discard Pile
	var step3 := TutorialStep.new()
	step3.narration_text = "This is your DISCARD PILE. Cards you play go here."
	step3.highlight_node_path = "BattleUI/DiscardPileButton"
	step3.action_type = TutorialStep.ActionType.NONE
	step3.auto_advance_delay = 4.0
	step3.block_all_except_highlight = true
	steps.append(step3)
	
	# Step 4: Play a Card to Demonstrate Discard
	var step4 := TutorialStep.new()
	step4.narration_text = "Play any card. It will be added to your discard pile!"
	step4.highlight_node_path = "BattleUI/Hand"
	step4.action_type = TutorialStep.ActionType.PLAY_CARD
	step4.block_all_except_highlight = false
	steps.append(step4)
	
	# Step 5: Check Discard Pile
	var step5 := TutorialStep.new()
	step5.narration_text = "The card you played has been addded to your discard pile!"
	step5.highlight_node_path = "BattleUI/DiscardPileButton"
	step5.action_type = TutorialStep.ActionType.NONE
	step5.auto_advance_delay = 4.0
	step5.block_all_except_highlight = false
	steps.append(step5)
	
	# Step 6: Explain Deck Cycling
	var step6 := TutorialStep.new()
	step6.narration_text = "When your Draw Pile is empty, your Discard Pile shuffles back into it!"
	step6.action_type = TutorialStep.ActionType.NONE
	step6.auto_advance_delay = 4.0
	step6.block_all_except_highlight = true
	steps.append(step6)
	
	# Step 7: Explain Card Management
	var step7 := TutorialStep.new()
	step7.narration_text = "Managing your deck is key! Know what cards you have available."
	step7.action_type = TutorialStep.ActionType.NONE
	step7.auto_advance_delay = 4.0
	step7.block_all_except_highlight = true
	steps.append(step7)
	
	# Step 8: End Turn to See More Cards
	var step8 := TutorialStep.new()
	step8.narration_text = "Let's end the turn to see more cards in action!"
	step8.highlight_node_path = "BattleUI/EndTurnButton"
	step8.action_type = TutorialStep.ActionType.END_TURN
	step8.block_all_except_highlight = false
	steps.append(step8)
	
	# Step 9: Wait for Enemy
	var step9 := TutorialStep.new()
	step9.narration_text = "The enemy takes their turn..."
	step9.action_type = TutorialStep.ActionType.WAIT_ENEMY_TURN
	step9.block_all_except_highlight = true
	steps.append(step9)
	
	# Step 10: Observe Draw Pile Change
	var step10 := TutorialStep.new()
	step10.narration_text = "Notice your Draw Pile decreased as you drew new cards!"
	step10.highlight_node_path = "BattleUI/DrawPileButton"
	step10.action_type = TutorialStep.ActionType.NONE
	step10.auto_advance_delay = 4.0
	step10.block_all_except_highlight = true
	steps.append(step10)
	
	# Step 11: Final Message
	var step11 := TutorialStep.new()
	step11.narration_text = "You're ready! Use your deck wisely to win the battle!"
	step11.action_type = TutorialStep.ActionType.NONE
	step11.auto_advance_delay = 4.0
	step11.block_all_except_highlight = false
	steps.append(step11)
	
	return steps
