#!/bin/bash

#genelSorgu()=>Sistemde kurulu paket sayısını ekrana yazdırır

genelSorgu(){
    sonuc=$(dpkg -l | wc -l)
    echo "Sistemde kurulu paket sayısı: $sonuc"
}

#paketSorgu()=>Paket ismine göre kurulu olup olmadığı, bağımlılıkları ve bağımlılıklarının kurulu olup olmadıkları kontrol edilir.

paketSorgu(){
    # paket adı $1
    installedDepends=()
    notInstalledDepends=()
    dependsList=()
    paketKurulumu=$(dpkg -s $1 2>&1)
    kurulumu=$(echo $paketKurulumu | grep "is not installed")
    #echo ${#kurulumu}
    if [ ${#kurulumu} -eq 0 ];then
        echo "Istenilen $1 paketi sistemde kurulu."
    else
        echo "Istenilen $1 paketi sistemde kurulu degil."

        depends=$(apt-cache depends $1 | grep "Depends:" | cut -d ":" -f 2 )
        dependsCount=$(apt-cache depends $1 | grep "Depends:" | wc -l)
        echo " "
        echo "Paket için gerekli bağımlılıkların sayısı: $dependsCount"

        for word in $depends
        do
            dependsList+=($word)
            paketKontrol=$(dpkg -s $word 2>&1)
            kurulumuFlag=$(echo $paketKontrol | grep "is not installed")
            if [ ${#kurulumuFlag} -eq 0 ];then
                installedDepends+=($word)
            else
                notInstalledDepends+=($word)
            fi 
        done
        echo " "
        echo "Bağımlılıklar:"
        for (( i = 0 ; i < ${#dependsList[@]} ; i++ )); do               
            echo ${dependsList[i]}                                       
        done 
        echo " "
        echo "Sistemde yüklü olan bağımlılıklar:"
        for (( i = 0 ; i < ${#installedDepends[@]} ; i++ )); do               
            echo ${installedDepends[i]}                                       
        done
        echo " "
        echo "Sistemde yüklü olmayan ve indirilecek olan bağımlılıklar:"
        for (( i = 0 ; i < ${#notInstalledDepends[@]} ; i++ )); do               
            echo ${notInstalledDepends[i]}                                       
        done

        echo " "
        echo "Yüklenecek bağımlılıkların sayısı:${#notInstalledDepends[@]}"
    fi
  
}

# Kullanıcıdan hangi fonksiyonu çalıştırmak istediğine göre girdi alınması
# Geçersiz işlem numarası girildiğinde sonsuz döngü içinde kullanıcıya yapılmak istenilen işlemin sorulması

while [ true ]                                                      
do                                                                  
    echo "Yapılmak istenilen islemin numarasini yaziniz..." 
    echo "1-Sistemdeki paket sayisi(Genel Sorgu)"   
    echo "2-Paket adina gore kontrol(Paket Sorgusu)"
    echo "3-Cikis"        
    read islem                                                                                                         
    if [ $islem -eq 1 ];then     
        genelSorgu 
        break                         
    elif [ $islem -eq 2 ];then
        echo "Paket adini giriniz.."
        read paketAdi
        paketSorgu $paketAdi
        break
    elif [ $islem -eq 3 ];then
        break
    else
        echo "Geçersiz işlem"
    fi
done

