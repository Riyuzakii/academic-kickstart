+++
title = "Value Prediction in the Multi-core Era"
date = "2019-02-10"
# View.
#   1 = List
#   2 = Compact
#   3 = Card
view = 2

# Optional featured image (relative to `static/img/` folder).
[header]
image = ""
caption = ""
+++

On Jan. 29th, 2019 we had a guest lecture from Dr. Arthur Perais, from Microsoft. Dr. Perais works on core architecture in general but specializes in Value Prediction techniques and talked about the same. Value prediction was first introduced in the mid-1990s by several research groups independently. But at the time it’s fame was ephemeral, as the community realized the insuperable nature of its implementation. It’s only with the Dennard Scaling and the slow down of Moore’s law that the researchers are looking in every direction(±x, ±y, ±z, and ±t) to find ways to improve performance. 
Now, If you’ve heard of speculative execution, the chances are that you’ve heard of or can guess what value prediction is. The basic idea is to predict the results of instructions based on previously seen results.


**Modified Pipeline for Value Prediction**
{{< figure library="1" src="valueprediction/pipeline.jpeg" title="Modified Pipeline for Value Prediction" >}}
As you can see from the figure, the predictor can be accessed from the fetch stage of the pipeline using the PC of the instructions. The result of the prediction is then written to a Physical Register File(PRF), but we could have used a dedicated buffer equally well. Any dependent instructions can consider the result stored in the PRF as ready and process further. Then, like all speculative techniques, we verify whether the prediction was correct or not. A correct prediction saves some cycles while an incorrect prediction leads to either re-execution of all dependent instructions or flushing of the pipeline. The final step is to train the predictor with the result of the current instruction. Now, we’re finally ready to move to the actual content of the talk. I would advise my unassuming readers to make sure that they understand the basics of value prediction before moving on.

Dr. Perais, at length, discussed the ways to bring VP back into the mainframe and make it feasible. So, how can we fix VP and what is there to fix? The answer, taken verbatim from his slides, can be stated as follows,

* Validation and recovery

* Revisiting context-based prediction

* Additional Register File ports

**Validation and Recovery**

Prediction validation requires a comparator that has to be added near the pipeline, as shown in the figure above. Not only does this demand extra hardware but puts pressure on the register file that has been added. He also discussed two ways of recovery,

_Pipeline Squashing_: this approach entails squashing the pipeline on an incorrect prediction; while the implementation is simple, the recovery process is slow.

_Selective Replay_: instead of squashing the whole pipeline we just replay the instructions dependent on the incorrect prediction. 
Common sense would suggest that the SR method should be faster and it is, but it’s also more complex to implement. Despite its various virtues, Dr. Perais argues that it’s best to get rid of SR. With convincing arguments such as its contention with speculative execution and the fact that there is no guarantee on the depth of the dependency chain that needs to be replayed, I, as a listener was convinced. So we look towards the other option, the slow and simple pipeline squashing could be used. 
The overall penalty would be roughly equal to the number of mispredictions multiplied by the penalty of a single misprediction. So if we have a high penalty for misprediction(recovery), we might want to reduce the number of mispredictions. Assuming a high accuracy, we can validate and recover via full pipeline squash at the time of commit.
{{< figure library="1" src="valueprediction/plot.jpeg" title="" >}}

The 3-bit confidence counter, represented by white bars, increments on every correct prediction and a prediction is made only when the counter is saturated. The blue bar, on the other hand, represents a 3-bit forward probabilistic counter, which increments on every correct prediction with a low probability(say 1/8) to mimic wider counters(higher accuracy). On the left side of the figure, where a fast recovery scheme(SR) is used both counters perform equally well, but in the case of a slower recovery mechanism, the speedup for 3-bit FPC with higher accuracy is significantly higher than the normal confidence counter. We can conclude from the figure that when the accuracy is high enough(99.5–99.9%), we can get by with a slower(and simpler) recovery mechanism.

Revisiting context-based prediction
Context-based predictors try to identify recurring patterns to make predictions. Finite Context Method(FCM) is one such predictor. Interested readers might want to go through these links[1][2], to get a better idea about FCM and context-based predictors in general. Dr. Perais also introduced other predictors such as the Value TAGE (VTAGE) and the differential VTAGE predictor, comparing them with the context-based predictors. The VTAGE predictors proved to be virtuous against the FCM predictors by eliminating the need for a speculative window which is required for consistent predictions in FCM and the restraint over predicting instructions in tight loops for value-history based predictors.

**Additional Register File Ports**

Now that we have ventured to fix the problems with recovery and modeled state-of-the-art predictors, we can finally take into consideration the cost we will have to endure to fulfill the requirements of such a system. The Physical Register File(PRF) from the first figure is now, with the introduction of VP, receiving one more write from the predictor and then is being read from, for the validation and further training of the predictor. Assuming a strict RISC based microarchitecture, for a 6-issue baseline, we’ll need 12 read ports and six write ports(12R/6W).
Along with the VP(8-wide), we’ll need eight more ports to write eight predictions per cycle, and eight more read ports to validate/train eight instructions per cycle (20R/14W). If we intend to convince the community to adopt VP, increasing the number of R/W ports on the PRF to such an extent is not the way to go.

**Leveraging the “Hidden” Benefits of VP**

Since we are using value prediction to predict the results of instructions, dependent instructions might be able to use the predicted values eliminating the need to execute some instructions before retirement and thus reducing pressure on the PRF. VP can also be used to bypass the decode stage and jump directly to execute stage in the cases where it provides instructions with ready operands. So, some instructions can be executed late, at the time of retirement and some can be considered to executed early(execution ready instructions) and the rest go through the usual Out-of-Order engine, Dr. Perais introduce what is called EOLE: {Early | OoO | Late} Execution. Fewer instructions now enter the instruction queue(IQ), this helps us reduce the issue width, which means lower power consumption and a faster execution engine. Furthering this with sharing of ports and banking of the PRF, he was able to show that we can bring down the number of ports to 12R/6W, same as the normal pipeline but with VP and a 33% smaller issue-width(6 — >4).

With this, we have fixed all the problems that were stated earlier and are in a position to appreciate the benefits of VP. Owing to the long and slow design cycle adopted by the industry it’ll be a few years before we see VP in actual systems.

That's all folks!

References:

1. Dr. Arthur Perais and his slides [_Both images were taken from his slides._]

2. http://www.cs.cmu.edu/afs/cs/academic/class/15740-f03/www/lectures/ValuePredictionDisc.htm