package io.aegis.mock
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.*
import androidx.compose.ui.unit.dp
enum class Scenario{P1_WIN_P2_LOSS,P1_LOSS_P2_WIN,BOTH_WIN,BOTH_LOSS,CONNECTION_FAILURE,UNKNOWN_RESULT,FROZEN,TARGET_RESTART,LAYOUT_CHANGE,DUPLICATE_EVENT}
class MainActivity:ComponentActivity(){override fun onCreate(b:Bundle?){super.onCreate(b);setContent{MaterialTheme(colorScheme=darkColorScheme()){Target()}}}}
@Composable fun Target(){var sc by remember{mutableStateOf(Scenario.P1_WIN_P2_LOSS)};var run by remember{mutableStateOf(false)};var round by remember{mutableIntStateOf(84721)};var p1 by remember{mutableStateOf("READY")};var p2 by remember{mutableStateOf("READY")};Column(Modifier.fillMaxSize().padding(16.dp),verticalArrangement=Arrangement.spacedBy(10.dp)){Text("MOCK AVIATION TARGET",style=MaterialTheme.typography.headlineSmall);Text("Balance 10000.00",Modifier.semantics{contentDescription="balance"});Text(if(run)"Round running 1.62x" else "Round $round betting open",Modifier.semantics{contentDescription="round status multiplier"});Panel("Panel 1",p1,{p1="OPEN"},{p1="CASHED OUT"});Panel("Panel 2",p2,{p2="OPEN"},{p2="CASHED OUT"});Button({run=!run;if(!run){round++;when(sc){Scenario.P1_WIN_P2_LOSS->{p1="WON";p2="LOST"};Scenario.P1_LOSS_P2_WIN->{p1="LOST";p2="WON"};Scenario.BOTH_WIN->{p1="WON";p2="WON"};Scenario.BOTH_LOSS->{p1="LOST";p2="LOST"};Scenario.UNKNOWN_RESULT->{p1="UNKNOWN";p2="UNKNOWN"};else->{}}}}){Text(if(run)"CRASH / FINISH" else "START ROUND")};Scenario.entries.forEach{TextButton({sc=it}){Text((if(sc==it)"✓ " else "")+it.name)}}}}
@Composable fun Panel(n:String,state:String,bet:()->Unit,cash:()->Unit){Card{Column(Modifier.fillMaxWidth().padding(12.dp)){Text(n);OutlinedTextField("1.00",{},label={Text("Stake")},modifier=Modifier.semantics{contentDescription="$n stake input"});Row{Button(bet,Modifier.semantics{contentDescription="$n place bet"}){Text("PLACE BET")};Spacer(Modifier.width(8.dp));Button(cash,Modifier.semantics{contentDescription="$n cash out"}){Text("CASH OUT")}};Text("Result $state")}}}
