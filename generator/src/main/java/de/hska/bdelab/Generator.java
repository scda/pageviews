package de.hska.bdelab;

import java.util.Date;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

public class Generator {


	public Generator(){

	}

	public void Run(){
		while(true) {
			// create ViewObject with "randomvalues"
			ViewObject vo = new ViewObject(GenerateTimestamp(),
											GenerateIp(),
											GenerateUri(),
											GenerateUid());

			System.out.println(vo.getTimestamp() + " - " + vo.getIp() + " - " + vo.getUri() + " - " + vo.getUid());

			// write viewobject to kafka ... in some way

			try {
				Thread.sleep(ThreadLocalRandom.current().nextInt(100,10000));
			} catch (InterruptedException e) { e.printStackTrace(); }
		}

	}

	// helpers
	private String GenerateTimestamp() {
		return (new Date()).toString();
	}
	private String GenerateIp() {
		return (rndDecByte()+"."+rndDecByte()+"."+rndDecByte()+"."+rndDecByte());
	}
	private String GenerateUri() {
		return ("http://bdelab.hska.de/pageviews/");
	}
	private String GenerateUid() {
		return (UUID.randomUUID().toString());
	}

	private String rndDecByte() {
		return String.valueOf(ThreadLocalRandom.current().nextInt(0, 256));
	}




}
