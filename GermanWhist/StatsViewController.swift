//
//  StatsViewController.swift
//  GermanWhist
//
//  Created by Earnest Wheeler on 12/14/14.
//  Copyright (c) 2014 GoldWheels. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var mostTricksLabel: UILabel!
    @IBOutlet weak var gamesWonLabel: UILabel!
    @IBOutlet weak var totalGamesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        totalGamesLabel.text = "Total Games: \(StatsManager.sharedStatsManager.stats.totalGames)"
        gamesWonLabel.text = "Games Won: \(StatsManager.sharedStatsManager.stats.gamesWon)"
        mostTricksLabel.text = "Most Tricks Won: \(StatsManager.sharedStatsManager.stats.mostTricksWon)"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
