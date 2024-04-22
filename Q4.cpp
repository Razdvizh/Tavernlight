void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
    Player* player = g_game.getPlayerByName(recipient);
    if (!player) {
        player = new Player(nullptr); //Allocate memory for `player`.
        if (!IOLoginData::loadPlayerByName(player, recipient)) {
            delete player; //Free `player`'s allocated memory before exiting.
            return;
        }
    }

    Item* item = Item::CreateItem(itemId); //`item` allocation.
    if (!item) {
        //player is offline meaning that the `player` was temporarily allocated in this function and needs to be freed before exiting.
        if (player->isOffline()) delete player;
        return;
    }

    g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

    //No need to free `item`, it's stored in player's (presumably) inventory and the resource is still accessible.

    if (player->isOffline()) {
        IOLoginData::savePlayer(player); //Serialize `player` with the `item`.
        //Player's data is saved and player is offline meaning that, at the moment, the player is loaded in memory 
        //in this function only and needs to be freed before exiting.
        delete player;
    }

    //No need to free memory of the online player!
}
