package io.aegis
import android.content.Context
import androidx.room.*
@Entity(tableName="events")data class Event(@PrimaryKey val id:String,val time:Long,val env:String,val type:String,val round:String?,val panel:String?,val previous:String?,val next:String?,val source:String,val confidence:Double,val message:String?)
@Entity(tableName="state")data class Persisted(@PrimaryKey val key:String,val value:String,val updated:Long)
@Entity(tableName="actions",indices=[Index(value=["round","panel"],unique=true)])data class Action(@PrimaryKey val id:String,val round:String,val panel:String,val stake:String,val state:String,val outcome:String?)
@Entity(tableName="mappings")data class Mapping(@PrimaryKey val id:String,val pkg:String,val version:Int,val fingerprint:String,val payload:String,val valid:Boolean)
@Dao interface AegisDao{@Insert(onConflict=OnConflictStrategy.REPLACE)suspend fun state(s:Persisted);@Insert suspend fun event(e:Event);@Insert(onConflict=OnConflictStrategy.ABORT)suspend fun action(a:Action);@Insert(onConflict=OnConflictStrategy.REPLACE)suspend fun mapping(m:Mapping);@Query("SELECT * FROM actions WHERE state!='RESOLVED'")suspend fun unresolved():List<Action>}
@Database(entities=[Event::class,Persisted::class,Action::class,Mapping::class],version=1,exportSchema=false)abstract class DB:RoomDatabase(){abstract fun dao():AegisDao;companion object{fun open(c:Context)=Room.databaseBuilder(c,DB::class.java,"aegis.db").build()}}