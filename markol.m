%*****************************************************************************
%----------   MODELS AND SIMULATION OF AGRICULTURAL SYSTEMS     --------------
% MARKOL simulation basic program
%        dtentr       : minimum time interval between customer arrivals
%        pr           : probability of customer arrival in dtentr.
%        maxworkhours : maximum working hours for the markol simulation [min].
%        dtshopmin    : minimum time interval a customer spends in the shop.
%        dtshopmax    : maximum time interval a customer spends in the shop.
%        dtservmin    : minimum time interval a customer is being served at 
%                       the cashier.
%        dtservmax    : maximum time interval a customer is being served at
%                       the cashier.
%******************************************************************************
%        written by Victor Alchanatis, modified by Rafi Linker
%        last update: 30/03/97
%==============================================================================
% INPUT OF PARAMETERS AND INITIALIZATION OF VARIABLES
%-----------------------------------------------------
clear;
cth1=[];cth2=[];ccmax_waiting_time=[];ccav_waiting_time=[];ccav_cash_wait=[];
ccmax_cash_wait=[];cctot_cash_wait=[];
clf;
hold off
rand('seed',10000);
format compact;

maxworkhours=8*60;  % MIN
dtentr=1;  %MIN

dtshopmin=2.0;      % min
dtshopmax=20.0;     % min
dtservmin=1.0;      % min
dtservmax=5;        % min

nsim=2;
minarea=0.40;
maxarea=0.45;
areastep=0.05;
%******************************************************************************

for area=maxarea:-areastep:minarea
   pr=0.1*area/0.1;
   th1=[];th2=[];cmax_waiting_time=[];cav_waiting_time=[];
   cmax_cash_wait=[];cav_cash_wait=[];ctot_cash_wait=[];
   
   for sim=1:nsim
% ARRIVAL TIME COMPUTATION
%--------------------------
      texit=[];
                              % vector with all time intervals
      pot_time_arr=0:dtentr:maxworkhours;
                              % vector with '1' where a customer may arrive
      customers=rand(size(pot_time_arr))<pr;
                              % vector with the first point of the interval
                              % during which a customer arrives
      tent=pot_time_arr(customers==1);
      maxcl=length(tent);
      disp(sprintf('Total number of customers                             %2.3g    '...
           ,maxcl))

                              % time interval between customer arrivals
      dtent=tent-[0,tent(1:maxcl-1)];
      pot_time_arr=[];customers=[];

% COMPUTATION OF THE TIME AT WHICH EACH CUSTOMER WILL PROCEED TO THE LINE
%-------------------------------------------------------------------------
                               % vector of random shopping time intervals
      dtshop=rand(1,maxcl)*(dtshopmax-dtshopmin)+dtshopmin;
                               % vector of absolute time at which each customer
                               % will proceed to the line (NOT SORTED)
      tline=tent+dtshop;

% SORTING OF THE CUSTOMERS ACCORDING TO THE TIME THEY PROCEED TO THE LINE
%------------------------------------------------------------------------
      [tmp,i]=sort(tline);
      clear tmp;                     % tmp is no longer needed
      alldata=[(1:maxcl)'  dtent' tent' dtshop' tline'];
      alldatasorted=alldata(i,:);
      sortline=alldatasorted(:,5)';

% COMPUTATION OF SERVICE TIME FOR EACH CUSTOMER
%----------------------------------------------
      dtserv=rand(1,maxcl)*(dtservmax-dtservmin)+dtservmin;

 
% COMPUTATION OF THE EXIT TIME OF EACH CUSTOMER
%----------------------------------------------
      texit(1)=sortline(1)+dtserv(1);
      for i=2:maxcl
        texit(i)=max(texit(i-1) , sortline(i)) + dtserv(i);
      end
% MATRIX THAT CONTAINS ALL THE DATA
%-----------------------------------
      finaldata=[alldatasorted dtserv' texit'];

% VECTOR OF THE TIME THAT EACH CUSTOMER HAS SPENT WAITING IN THE LINE
%--------------------------------------------------------------------
      wait=(texit-dtserv-sortline)';

% MAXIMUM TIME OF A SINGLE CUSTOMER WAITING  IN THE LINE
%-------------------------------------------------------
      max_waiting_time=max(wait);
      cmax_waiting_time=[cmax_waiting_time ; max_waiting_time];

% AVERAGE TIME OF WAITING IN THE LINE
%------------------------------------
      av_waiting_time=mean(wait);
      cav_waiting_time=[cav_waiting_time ; av_waiting_time];
    
% TIME THAT THE CASHIER WAITS BETWEEN CUSTOMERS (EMPTY LINE)
%-----------------------------------------------------------
      cashier_wait=(sortline(2:maxcl)-texit(1:maxcl-1));
      ii=find(cashier_wait>0);

      cashier_wait=cashier_wait.*(cashier_wait>0);
      max_cash_wait=max(cashier_wait(ii));
      cmax_cash_wait=[cmax_cash_wait ; max_cash_wait ];
      av_cash_wait=mean(cashier_wait);
      cav_cash_wait=[cav_cash_wait ; av_cash_wait];

      tot_cash_wait=sum(cashier_wait(ii));
      ctot_cash_wait=[ctot_cash_wait ; tot_cash_wait];

                                  % Plot of the line length vrs time 
      a=[sortline' ones(maxcl,1)
         texit'    (-1)*ones(maxcl,1)];
      [tmp,ii]=sort(a(:,1));
      clear tmp;
      a=a(ii,:);
      for k=2:length(a)
         a(k,2)=a(k-1,2)+a(k,2);
      end
      figure(1)
      clf
      stairs(a(:,1)/60,a(:,2));
      grid
      title('LINE AT THE CASHIER VRS TIME')
      xlabel('TIME [hours]')
      ylabel('LINE LENGTH')
      pause

      [h1,nn1]=hist(texit'-alldatasorted(:,3),0:5:250);
      th1=[th1 ; h1];
      [h2,nn2]=hist(wait,0:5:250);
      th2=[th2 ; h2];

      
   end                        % nsim loop

   th1=mean(th1);  cth1=[cth1 ; th1];
   th2=mean(th2);  cth2=[cth2 ; th2];
   figure(1)
   subplot(211)
   plot(nn1,th1)
   grid
   title('AVERAGE HISTOGRAM OF TOTAL TIME SPENT IN THE SHOP')
   xlabel('TIME [minutes]')
   ylabel('No OF CUSTOMERS')

   subplot(212)
   plot(nn2,th2)
   grid
   title('AVERAGE HISTOGRAM OF WAITING TIME AT THE CASHIER LINE')
   xlabel('TIME [minutes]')
   ylabel('No OF CUSTOMERS')
   pause

   max_waiting_time=mean(cmax_waiting_time);
   disp(sprintf('Maximun time that a customer waits in the line        %2.3g min'...
       ,max_waiting_time))
   ccmax_waiting_time=[ccmax_waiting_time ; max_waiting_time];

   av_waiting_time=mean(cav_waiting_time);
   disp(sprintf('Average time that a customer waits in the line:       %2.3g min'...
        ,av_waiting_time))
   ccav_waiting_time=[ccav_waiting_time ; av_waiting_time];

         
   max_cash_wait=mean(cmax_cash_wait );
   ccmax_cash_wait=[ccmax_cash_wait ; max_cash_wait];
   av_cash_wait=mean(cav_cash_wait);
   ccav_cash_wait=[ccav_cash_wait ; av_cash_wait];
   disp(sprintf('Maximum time that the cashier line is empty:          %2.3g min'...
        ,max_cash_wait))
   disp(sprintf('Average time that the cashier line is empty:          %2.3g min'...
        ,av_cash_wait))

   tot_cash_wait=mean(ctot_cash_wait);
   cctot_cash_wait=[cctot_cash_wait ; tot_cash_wait];
   disp(sprintf('Total time that the cashier line is empty:            %2.3g min'...
        ,tot_cash_wait))
end                        % of area loop
